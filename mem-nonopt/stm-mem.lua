STMMemoryLogger = StateMachine:new()

local IDLE, ACTIVE = 1, 2
local T1, T2 = "t1", "t2"
local MEASURE_INTERVAL = 100*Timer.BASE
local SEND_INTERVAL = 1000*Timer.BASE
local CONN_ID = "stm_tc1"
local CONN_EVENT = STMTcpClient.events.SEND
local ASSOCIATE_ID = "stm_l1"
local ASSOCIATE_EVENT = 2 -- STMLogger.events.LOG

STMMemoryLogger.events = {
	START = 1,
	STOP = 2,
	MEASURE = 3,
	SEND_DATA = 4,
}

function STMMemoryLogger:schedule_measure(timer_no)
	local event = Event:new(self:id(), self.events.MEASURE)
	local timer = Timer:new(self:id()..timer_no, MEASURE_INTERVAL, event)
	event:set_timer_id(timer_no)
	self.scheduler:add_timer(timer)
end

function STMMemoryLogger:schedule_send(timer_no)
	local event = Event:new(self:id(), self.events.SEND_DATA)
	local timer = Timer:new(self:id()..timer_no, SEND_INTERVAL, event)
	event:set_timer_id(timer_no)
	self.scheduler:add_timer(timer)
end

function STMMemoryLogger:measure()
	local mem = collectgarbage("count")
	table.insert(self.measurements, mem)
end

function STMMemoryLogger:send_data(event)
	print("Sending data...")
	local data = ""
	for i,v in ipairs(self.measurements) do
		data = data..v.." "
	end
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = data})
	local event = Event:new(CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
	self.measurements = {}
end

function STMMemoryLogger:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = IDLE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	o.measurements = {}
	return o
end

function STMMemoryLogger:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == IDLE then
			if event:type() == self.events.START then
				print("Memory logger started!")
				self:schedule_measure(T1)
				self:schedule_send(T2)
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			if event:type() == self.events.MEASURE then
				self:measure()
				self:schedule_measure(T1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.SEND_DATA then
				self:schedule_send(T2)
				self:send_data()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				self:set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end

	end
end