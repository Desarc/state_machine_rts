STMMemoryLog = StateMachine:new()

local ACTIVE, IDLE = "active", "idle"
local T1, T2 = "t1", "t2"
local MEASURE_INTERVAL = 100*Timer.BASE
local SEND_INTERVAL = 1000*Timer.BASE
local CONN_ID = "stm_ec1"
local CONN_EVENT = STMExternalConnection.events.SEND_MESSAGE
local ASSOCIATE_ID = "stm_l1"
local ASSOCIATE_EVENT = 2 -- STMLogger.events.LOG

STMMemoryLog.events = {
	START = 1,
	STOP = 2,
	MEASURE = 3,
	SEND_DATA = 4,
}

function STMMemoryLog:schedule_measure(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.MEASURE)
	timer = self:set_timer(timer, self:id()..timer_no, MEASURE_INTERVAL, event)
	event:set_timer(timer)
end

function STMMemoryLog:schedule_send(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.SEND_DATA)
	timer = self:set_timer(timer, self:id()..timer_no, SEND_INTERVAL, event)
	event:set_timer(timer)
end

function STMMemoryLog:measure()
	-- measuring queue lengths or memory use
	--local events = self.scheduler:event_queue_length()
	--local timers = self.scheduler:timer_queue_length()
	local mem = collectgarbage("count")
	--table.insert(self.measurements, events+timers)
	table.insert(self.measurements, mem)
end

function STMMemoryLog:send_data(event)
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = table.concat(self.measurements, " ")})
	local event = self:create_event(event, CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
	-- assign nil values instead of setting measurements = {}
	-- this is cleaner and conserves memory
	for i in ipairs(self.measurements) do
		self.measurements[i] = nil
	end
end

function STMMemoryLog:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = IDLE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	o.measurements = {}
	return o
end

function STMMemoryLog:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == IDLE then
			if event:type() == self.events.START then
				print("Queue length observer started!")
				self:schedule_measure(T1, event, event:timer())
				self:schedule_send(T2, nil, nil)
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			if event:type() == self.events.MEASURE then
				self:measure()
				self:schedule_measure(T1, event, event:timer())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.SEND_DATA then
				self:schedule_send(T2, event, event:timer())
				self:send_data(nil)
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

return STMMemoryLog