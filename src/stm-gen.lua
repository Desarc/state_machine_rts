-- assume modules are loaded by main
--local StateMachine = require "stm"
--local Timer = require "timer"
--local Event = require "event"
--local STMSimpleTask = require "stm-task"

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local EVENT_INTERVAL = 0.1*Timer.BASE
local EVENT_TARGET = "stm_st1"	-- STMSimpleTask

local STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMEventGenerator:schedule_self(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.GENERATE)
	timer = self:set_timer(timer, self:id()..timer_no, EVENT_INTERVAL, event)
	event:set_timer(timer)
end

function STMEventGenerator:schedule_task(event)
	event = self:create_event(event, EVENT_TARGET, STMSimpleTask.events.RUN_TASK)
	self.scheduler:add_event(event)
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == INACTIVE then
			if event:type() == self.events.START then
				self:schedule_self(T1, event, event:timer())
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
				
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.RUN_TASK then
				self:schedule_self(T1, event, event:timer())
				self:schedule_task(nil)
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