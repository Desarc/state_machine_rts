-- assume modules are loaded my main
--local StateMachine = require "stm"
--local Timer = require "timer"
--local Event = require "event"

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local COLLECT_INTERVAL = 500*Timer.BASE

local STMGarbageCollector = StateMachine:new()

STMGarbageCollector.events = {
	START = 1,
	STOP = 2,
	COLLECT = 3,
}

function STMGarbageCollector:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMGarbageCollector:schedule_self(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.COLLECT)
	timer = self:set_timer(timer, self:id()..timer_no, COLLECT_INTERVAL, event)
	event:set_timer(timer)
end

function STMGarbageCollector:fire()
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
			if event:type() == self.events.COLLECT then
				self:schedule_self(T1, event, event:timer())
				collectgarbage()
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

return STMGarbageCollector