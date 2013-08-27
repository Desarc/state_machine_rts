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
	scheduler:stop_timer(id)
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

function PeriodicTimer:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function PeriodicTimer:fire()
	while(true) do
		print("Handling event in PeriodicTimer...")
		event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif self.data.current_state == IDLE then
			if event:type() == self.events.START then
				timer_start()
				local event = Event:new(self.data.id, self.events.TIMEOUT)
				local timer = Timer:new(os.time()+TIMEOUT_TIME, self.data.id, event)
				self.data.current_timer_id = timer:id()
				self.scheduler:add_timer(timer)
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
				self.scheduler:add_timer(Timer:new(os.time()+TIMEOUT_TIME, self.data.id, event))
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

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return TrafficLightController