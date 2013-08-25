require "state_machine"
require "timer"
require "event"

local ACTIVE, IDLE = "Active", "Idle"
local TIMEOUT_TIME = 5

local function timer_start()
	print("Timer started.")
end

local function stm_exit()
	print("Exiting.")
end

local function tick()
	print("Tick!")
end

local function timer_stop(id, scheduler)
	print("Stopping timer...")
	scheduler.stop_timer(id)
end

local function cars_show_green()
	print("Car light set to green.")
end

PeriodicTimer = StateMachine:new()

PeriodicTimer.events = {
	START = 1,
	STOP = 2,
	TIMEOUT = 3,
	EXIT = 4,
}

function PeriodicTimer:new(id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.data = {id = id, current_state = IDLE}
	return o
end

function PeriodicTimer:id()
	return self.data.id
end

function PeriodicTimer:fire(event, scheduler)
	
	while(true) do
		print("Event received!")
		print(self.data.current_state)
		print(event:type())
		if self.data.current_state == IDLE then
			if event:type() == self.events.START then
				timer_start()
				local event = Event:new(self.data.id, self.events.TIMEOUT)
				local timer = Timer:new(os.time()+TIMEOUT_TIME, self.data.id, event)
				self.data.current_timer_id = timer:id()
				scheduler.add_timer(timer)
				self.data.current_state = ACTIVE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				stm_exit()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			
			end
		
		elseif self.data.current_state == ACTIVE then
			if event:type() == self.events.TIMEOUT then
				tick()
				local event = Event:new(self.data.id, self.events.TIMEOUT)
				scheduler.add_timer(Timer:new(os.time()+TIMEOUT_TIME, self.data.id, event))
				self.data.current_state = ACTIVE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				timer_stop(self.data.current_timer_id, scheduler)
				self.data.current_state = IDLE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				stm_exit()
				self.data.current_state = IDLE
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			end

		end

		coroutine.yield(StateMachine.DISCARD_EVENT)
	end

end

return TrafficLightController