require "state_machine"
require "timer"
require "event"

local S0, S1, S2, S3, S4, S5 = "S0", "S1", "S2", "S3", "S4", "S5"
local YELLOW_DELAY = 3
local PEDESTRIAN_TIME = 10
local SAFE_TIME = 1

local function peds_show_red()
	print("Pedestrian light set to red.")
end

local function peds_show_green()
	print("Pedestrian light set to green.")
end

local function cars_show_red()
	print("Car light set to red.")
end

local function cars_show_yellow()
	print("Car light set to yellow.")
end

local function cars_show_green()
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

function TrafficLightController:new(id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.data = {id = id, current_state = S0}
	return o
end

function TrafficLightController:id()
	return self.data.id
end

function TrafficLightController:fire(event, scheduler)

	if self.data.current_state == S0 then
		if event:type() == self.events.PEDESTRIAN_BUTTON_PRESSED then
			cars_show_yellow()
			local event = Event:new(self.data.id, self.events.YELLOW_TIMER_EXPIRED)
			scheduler.add_timer(Timer:new(os.time()+YELLOW_DELAY, self.data.id, event))
			self.data.current_state = S1
			return StateMachine.EXECUTE_TRANSITION
		end
	
	elseif self.data.current_state == S1 then
		if event:type() == self.events.YELLOW_TIMER_EXPIRED then
			cars_show_red()
			local event = Event:new(self.data.id, self.events.PEDESTRIANS_GO)
			scheduler.add_timer(Timer:new(os.time()+SAFE_TIME, self.data.id, event))
			self.data.current_state = S2
			return StateMachine.EXECUTE_TRANSITION
		end

	elseif self.data.current_state == S2 then
		if event:type() == self.events.PEDESTRIANS_GO then
			peds_show_green()
			local event = Event:new(self.data.id, self.events.PEDESTRIAN_TIMER_EXPIRED)
			scheduler.add_timer(Timer:new(os.time()+PEDESTRIAN_TIME, self.data.id, event))
			self.data.current_state = S3
			return StateMachine.EXECUTE_TRANSITION
		end

	elseif self.data.current_state == S3 then
		if event:type() == self.events.PEDESTRIAN_TIMER_EXPIRED then
			peds_show_red()
			local event = Event:new(self.data.id, self.events.CARS_GO)
			scheduler.add_timer(Timer:new(os.time()+SAFE_TIME, self.data.id, event))
			self.data.current_state = S4
			return StateMachine.EXECUTE_TRANSITION
		end

	elseif self.data.current_state == S4 then
		if event:type() == self.events.CARS_GO then
			cars_show_yellow()
			local event = Event:new(self.data.id, self.events.YELLOW_TIMER_EXPIRED)
			scheduler.add_timer(Timer:new(os.time()+YELLOW_DELAY, self.data.id, event))
			self.data.current_state = S5
			return StateMachine.EXECUTE_TRANSITION
		end

	elseif self.data.current_state == S5 then
		if event:type() == self.events.YELLOW_TIMER_EXPIRED then
			cars_show_green()
			self.data.current_state = S0
			return StateMachine.EXECUTE_TRANSITION
		end

	end
	return StateMachine.DISCARD_EVENT


end

return TrafficLightController