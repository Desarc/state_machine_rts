--require "state_machine"
--require "timer"
--require "event"

StateMachine = dofile("/wo/state_machine.lua")
Timer = dofile("/wo/timer.lua")
Event = dofile("/wo/event.lua")

local S0, S1, S2, S3, S4, S5 = "S0", "S1", "S2", "S3", "S4", "S5"
local YELLOW_DELAY = 3000000
local PEDESTRIAN_TIME = 10000000
local SAFE_TIME = 1000000

local function peds_show_red()

	-- change some registry or variable values...

	print("Pedestrian light set to red.")
end

local function peds_show_green()

	-- change some registry or variable values...

	print("Pedestrian light set to green.")
end

local function cars_show_red()

	-- change some registry or variable values...

	print("Car light set to red.")
end

local function cars_show_yellow()

	-- change some registry or variable values...

	print("Car light set to yellow.")
end

local function cars_show_green()

	-- change some registry or variable values...

	print("Car light set to green.")
end

TrafficLightController = StateMachine:new()

TrafficLightController.events = {
	PEDESTRIAN_BUTTON_PRESSED = 1,
	YELLOW_TIMER_EXPIRED = 2,
	PEDESTRIANS_GO = 3,
	PEDESTRIAN_TIMER_EXPIRED = 4,
	CARS_GO = 5,
}

function TrafficLightController:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self})
	o.data = {}
	o.data.id = id
	o.data.current_state = S0
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function TrafficLightController:fire()
	while(true) do
		event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif self.data.current_state == S0 then
			if event:type() == self.events.PEDESTRIAN_BUTTON_PRESSED then
				cars_show_yellow()
				local event = Event:new(self.data.id, self.events.YELLOW_TIMER_EXPIRED)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+YELLOW_DELAY, self.data.id, event))
				self.data.current_state = S1
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end
		
		elseif self.data.current_state == S1 then
			if event:type() == self.events.YELLOW_TIMER_EXPIRED then
				cars_show_red()
				local event = Event:new(self.data.id, self.events.PEDESTRIANS_GO)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+SAFE_TIME, self.data.id, event))
				self.data.current_state = S2
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end

		elseif self.data.current_state == S2 then
			if event:type() == self.events.PEDESTRIANS_GO then
				peds_show_green()
				local event = Event:new(self.data.id, self.events.PEDESTRIAN_TIMER_EXPIRED)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+PEDESTRIAN_TIME, self.data.id, event))
				self.data.current_state = S3
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end

		elseif self.data.current_state == S3 then
			if event:type() == self.events.PEDESTRIAN_TIMER_EXPIRED then
				peds_show_red()
				local event = Event:new(self.data.id, self.events.CARS_GO)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+SAFE_TIME, self.data.id, event))
				self.data.current_state = S4
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end

		elseif self.data.current_state == S4 then
			if event:type() == self.events.CARS_GO then
				cars_show_yellow()
				local event = Event:new(self.data.id, self.events.YELLOW_TIMER_EXPIRED)
				self.scheduler:add_timer(Timer:new(self.scheduler.time()+YELLOW_DELAY, self.data.id, event))
				self.data.current_state = S5
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end

		elseif self.data.current_state == S5 then
			if event:type() == self.events.YELLOW_TIMER_EXPIRED then
				cars_show_green()
				self.data.current_state = S0
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return TrafficLightController