StateMachine = require "stm"
Timer = require "timer"
Event = require "event"
STMSimpleTask = require "stm-task"

local INACTIVE, ACTIVE  = "inactive", "active"
local EVENT_INTERVAL = 10000

STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = INACTIVE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMEventGenerator:schedule_self()
	local event = Event:new(self:id(), self.events.GENERATE)
	self.scheduler:add_timer(Timer:new(self:id(), EVENT_INTERVAL, event)
end

function STMEventGenerator:schedule_event()
	local event = Event:new("stm_st1", STMSimpleTask.events.RUN_TASK)
	self.scheduler:add_to_queue(event)
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if current_state == INACTIVE then
			if event:type() == self.events.START then
				self:schedule_self()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
				
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.RUN_TASK then
				self:schedule_self()
				self:schedule_event()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			elseif event:type() == self.events.STOP then
				self:set_state(INACTIVE)
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