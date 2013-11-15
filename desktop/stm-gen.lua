local StateMachine = require "stm"
local Timer = require "timer"
local Event = require "event"
local STMSimpleTask = require "stm-task"

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local EVENT_INTERVAL = 1000*Timer.BASE
local EVENT_TARGET = "stm_st1"

local STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(INACTIVE)
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
	local event = Event:new(EVENT_TARGET, STMSimpleTask.events.RUN_TASK)
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