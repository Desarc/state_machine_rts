local StateMachine = require "stm"
local Event = require "event"
local Timer = require "timer"

local STMTrafficLightController = StateMachine:new()

local S0, S1, S2, S3, S4, S5 = 1, 2, 3, 4, 5, 6
local T1, T2, T3, T4, T5 = "t1", "t2", "t3", "t4", "t5"
local YELLOW_DELAY = 3000*Timer.BASE
local PEDESTRIAN_TIME = 10000.Timer.BASE
local SAFE_TIME = 1000*Timer.BASE

STMTrafficLightController.events = {
	PEDESTRIAN_BUTTON_PRESSED = 1,
	YELLOW_TIMER_EXPIRED = 2,
	PEDESTRIANS_GO = 3,
	PEDESTRIAN_TIMER_EXPIRED = 4,
	CARS_GO = 5,
}

function STMTrafficLightController:schedule_event(event_type, delay, timer_no)
	local event = Event:new(self.id(), event_type)
	local timer = Timer:new(self.id()..timer_no, delay, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMTrafficLightController:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = S0}
	local sched = scheduler

	o.id = function ()
		return data.id
	end

	o.state = function ()
		return data.state
	end

	o.set_state = function (state)
		data.state = state
	end

	o.scheduler = function ()
		return sched
	end

	scheduler.add_state_machine(o)
	return o
end

function STMTrafficLightController:fire()

	print("Pedestrian light set to red.")
	print("Car light set to green.")

	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == S0 then
			if event.type() == self.events.PEDESTRIAN_BUTTON_PRESSED then
				print("Car light set to yellow.")
				self:schedule_event(self.events.YELLOW_TIMER_EXPIRED, YELLOW_DELAY, T1)
				self.set_state(S1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == S1 then
			if event.type() == self.events.YELLOW_TIMER_EXPIRED and event.timer_id() == T1 then
				print("Car light set to red.")
				self:schedule_event(self.events.PEDESTRIANS_GO, SAFE_TIME, T2)
				self.set_state(S2)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S2 then
			if event.type() == self.events.PEDESTRIANS_GO and event.timer_id() == T2 then
				print("Pedestrian light set to green.")
				self:schedule_event(self.events.PEDESTRIAN_TIMER_EXPIRED, PEDESTRIAN_TIME, T3)
				self.set_state(S3)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S3 then
			if event.type() == self.events.PEDESTRIAN_TIMER_EXPIRED and event.timer_id() == T3 then
				print("Pedestrian light set to red.")
				self:schedule_event(self.events.CARS_GO, SAFE_TIME, T4)
				self.set_state(S4)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S4 then
			if event.type() == self.events.CARS_GO and event.timer_id() == T4 then
				print("Car light set to yellow.")
				self:schedule_event(self.events.YELLOW_TIMER_EXPIRED, YELLOW_DELAY, T5)
				self.set_state(S5)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == S5 then
			if event.type() == self.events.YELLOW_TIMER_EXPIRED and event.timer_id() == T5 then
				print("Car light set to green.")
				self.set_state(S0)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMTrafficLightController