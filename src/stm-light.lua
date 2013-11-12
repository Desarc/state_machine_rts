StateMachine = require "state_machine"
Timer = require "timer"
Event = require "event"

local S0, S1, S2, S3, S4, S5 = "S0", "S1", "S2", "S3", "S4", "S5"
local YELLOW_DELAY = 3000000
local PEDESTRIAN_TIME = 10000000
local SAFE_TIME = 1000000

TrafficLightController = StateMachine:new()

TrafficLightController.events = {
	PEDESTRIAN_BUTTON_PRESSED = 1,
	YELLOW_TIMER_EXPIRED = 2,
	PEDESTRIANS_GO = 3,
	PEDESTRIAN_TIMER_EXPIRED = 4,
	CARS_GO = 5,
}

function TrafficLightController:schedule_event(type, delay, timer_no)
	local event = Event:new(self:id(), type)
	local timer = Timer:new(self:id().."-"..timer_no, delay, self:id(), event))
	event:set_data(timer_no)
	self.scheduler:add_timer(timer)
end

function TrafficLightController:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self})
	o.data = {}
	o.data.id = id
	o.data.current_state = S0
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function TrafficLightController:fire()

	print("Pedestrian light set to red.")
	print("Car light set to green.")

	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if current_state == S0 then
			if event:type() == self.events.PEDESTRIAN_BUTTON_PRESSED then
				print("Car light set to yellow.")
				self:schedule_event(self.events.YELLOW_TIMER_EXPIRED, YELLOW_DELAY, "t1")
				self:set_state(S1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == S1 then
			if event:type() == self.events.YELLOW_TIMER_EXPIRED and event:get_data() == "t1" then
				print("Car light set to red.")
				self:schedule_event(self.events.PEDESTRIANS_GO, SAFE_TIME, "t2")
				self.set_state(S2)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S2 then
			if event:type() == self.events.PEDESTRIANS_GO and event:get_data() == "t2" then
				print("Pedestrian light set to green.")
				self:schedule_event(self.events.PEDESTRIAN_TIMER_EXPIRED, PEDESTRIAN_TIME, "t3")
				self:set_state(S3)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S3 then
			if event:type() == self.events.PEDESTRIAN_TIMER_EXPIRED and event:get_data() == "t3" then
				print("Pedestrian light set to red.")
				self:schedule_event(self.events.CARS_GO, SAFE_TIME, "t4")
				self:set_state(S4)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S4 then
			if event:type() == self.events.CARS_GO and event:get_data() == "t4" then
				print("Car light set to yellow.")
				self:schedule_event(self.events.YELLOW_TIMER_EXPIRED, YELLOW_DELAY, "t5")
				self:set_state(S5)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S5 then
			if event:type() == self.events.YELLOW_TIMER_EXPIRED and event:get_data() == "t5" then
				print("Car light set to green.")
				self:set_state(S0)
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