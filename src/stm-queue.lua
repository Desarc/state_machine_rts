local StateMachine = require "stm"
local Timer = require "timer"
local Event = require "event"
local STMExternalConnection = require "stm-conn"

local ACTIVE, IDLE = "active", "idle"
local T1 = "t1"
local MEASURE_INTERVAL = 100*Timer.BASE
local CONN_ID = "stm_ec1"
local ASSOCIATE_ID = "stm_l1"
local ASSOCIATE_EVENT = 2 -- STMLogger.events.LOG

local STMQueueLength = StateMachine:new()

STMQueueLength.events = {
	START = 1,
	STOP = 2,
	MEASURE = 3,
	SEND_DATA = 4,
}

function STMQueueLength:schedule_measure(timer_no)
	local event = Event:new(self.id(), self.events.MEASURE)
	local timer = Timer:new(self.id()..timer_no, MEASURE_INTERVAL, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMQueueLength:measure()
	local events = self.scheduler().event_queue_length()
	local timers = self.scheduler().timer_queue_length()
	table.insert(self.measurements, events+timers)
end

function STMQueueLength:send_data()
	local data = ""
	for k,v in pairs(self.measurements) do
		data = data..tostring(v).." "
	end
	self.measurements = {}
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = data})
	local event = Event:new(CONN_ID, STMExternalConnection.events.SEND_MESSAGE, message)
	self.scheduler().add_to_queue(event)
end

function STMQueueLength:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(IDLE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	o.measurements = {}
	return o
end

function STMQueueLength:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then
			if event.type() == self.events.START then
				print("Queue length observer started!")
				self:schedule_measure(T1)
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			if event.type() == self.events.MEASURE then
				self:measure()
				self:schedule_measure(T1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.SEND_DATA then
				self:send_data()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)


			elseif event.type() == self.events.STOP then
				self.set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMQueueLength