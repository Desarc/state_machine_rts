local StateMachine = require "stm"
local Timer = require "timer"
local Event = require "event"
local STMTcpClient = require "stm-tcp-client"
local STMPrintMessage = require "stm-print"

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local EVENT_INTERVAL = 1*Timer.BASE
local EVENT_TARGET = "stm_tc1"
local EVENT_TYPE = STMTcpClient.events.SEND
local ASSOCIATE_ID = "stm_pm1"
local ASSOCIATE_EVENT = STMPrintMessage.events.PRINT

local STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = INACTIVE}
	local sched = scheduler

	o.id = function ()
		return data.id
	end

	o.state = function ()
		return data.state
	end

	o.set_state = function (state)
		data.state = state
	end

	o.scheduler = function ()
		return sched
	end

	scheduler.add_state_machine(o)
	return o
end

function STMEventGenerator:schedule_self(timer_no)
	local event = Event:new(self.id(), self.events.GENERATE)
	local timer = Timer:new(self.id()..timer_no, EVENT_INTERVAL, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMEventGenerator:schedule_event()
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = "hello")
	local event = Event:new(EVENT_TARGET, EVENT_TYPE, message)
	self.scheduler().add_event(event)
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == INACTIVE then
			if event.type() == self.events.START then
				self:schedule_self(T1)
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
				
			end

		elseif current_state == ACTIVE then
			if event.type() == self.events.RUN_TASK then
				self:schedule_self(T1)
				self:schedule_event()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			elseif event.type() == self.events.STOP then
				self.set_state(INACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)

			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMEventGenerator