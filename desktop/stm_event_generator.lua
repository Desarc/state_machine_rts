require "state_machine"
require "timer"
require "event"

local ACTIVE, IDLE = "Active", "Idle"
local EVENT_INTERVAL = 0.001

local function generator_start()
	print("Event generator started!")
end

STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE_NEW = 3,
	EXIT = 4,
}

function STMEventGenerator:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif self.data.current_state == IDLE then
			if event:type() == self.events.START then
				generator_start()
				local event = Event:new(self.data.id, self.events.GENERATE_NEW)
				local timer = Timer:new(self.scheduler.time()+EVENT_INTERVAL, self.data.id, event)
				self.data.current_timer_id = timer:id()
				self.scheduler:add_timer(timer)
				self.data.current_state = ACTIVE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			
			end
		
		elseif self.data.current_state == ACTIVE then
			if event:type() == self.events.GENERATE_NEW then
				local event = Event:new(self.data.id, self.events.GENERATE_NEW)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+EVENT_INTERVAL, self.data.id, event))
				self.data.current_state = ACTIVE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				timer_stop(self.data.current_timer_id, scheduler)
				self.data.current_state = IDLE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMEventGenerator