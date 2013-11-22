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

function STMMemoryLogger:schedule_measure(timer_no, event, timer)
	event = self:create_event(event, self.id, self.events.MEASURE)
	timer = self:set_timer(timer, self.id..timer_no, MEASURE_INTERVAL, event)
	event.timer = timer
end

function STMMemoryLogger:schedule_send(timer_no, event, timer)
	event = self:create_event(event, self.id, self.events.SEND_DATA)
	timer = self:set_timer(timer, self.id..timer_no, SEND_INTERVAL, event)
	event.timer = timer
end

function STMMemoryLogger:measure()
	local mem = collectgarbage("count")
	table.insert(self.measurements, mem)
end

function STMMemoryLogger:send_data(event)
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = table.concat(self.measurements, " ")})
	local event = self:create_event(event, CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
	for i in ipairs(self.measurements) do
		self.measurements[i] = nil
	end
end

function STMMemoryLogger:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.id = id
	o.state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	o.measurements = {}
	return o
end

function STMMemoryLogger:fire(event)
	while(true) do

		if self.state == IDLE then
			if event.type == self.events.START then
				print("Queue length observer started!")
				self:schedule_measure(T1, event, event.timer)
				self:schedule_send(T2, nil, nil)
				self.state = ACTIVE
				return true, StateMachine.EXECUTE_TRANSITION

			else
				return true, StateMachine.DISCARD_EVENT
			end
		
		elseif self.state == ACTIVE then
			if event.type() == self.events.MEASURE then
				self:measure()
				self:schedule_measure(T1, event, event.timer)
				return true, StateMachine.EXECUTE_TRANSITION

			elseif event.type == self.events.SEND_DATA then
				self:schedule_send(T2, event, event.timer)
				self:send_data(nil)
				return true, StateMachine.EXECUTE_TRANSITION

			elseif event.type == self.events.STOP then
				self.state = IDLE
				return true, StateMachine.EXECUTE_TRANSITION

			else
				return true, StateMachine.DISCARD_EVENT
			end

		else
			return true, StateMachine.DISCARD_EVENT
		end

	end
end