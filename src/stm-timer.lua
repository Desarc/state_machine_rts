StateMachine = require "state_machine"
Timer = require "timer"
Event = require "event"

local ACTIVE, IDLE = "Active", "Idle"
local TIMEOUT_TIME = 5000000


PeriodicTimer = StateMachine:new()

PeriodicTimer.events = {
	START = 1,
	STOP = 2,
	TIMEOUT = 3,
}

function PeriodicTimer:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function PeriodicTimer:timer_start()
	print("Timer started.")
	local event = Event:new(self:id(), self.events.TIMEOUT)
	self.scheduler:add_timer(Timer:new(TIMEOUT_TIME, self:id(), event))
end


function PeriodicTimer:tick()
	print("Tick!")
	local event = Event:new(self:id(), self.events.TIMEOUT)
	self.scheduler:add_timer(Timer:new(TIMEOUT_TIME, self:id(), event))
end

function PeriodicTimer:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif current_state == IDLE then

			if event:type() == self.events.START then
				self:timer_start()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			
			if event:type() == self.events.TIMEOUT then
				self:tick()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				print("Stopping timer.")
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

return TrafficLightController