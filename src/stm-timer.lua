StateMachine = require "stm"
Timer = require "desktop-timer"
Event = require "event"

local ACTIVE, IDLE = "Active", "Idle"
local T1 = "t1"
local TIMEOUT_TIME = 1000*Timer.BASE

STMPeriodicTimer = StateMachine:new()

STMPeriodicTimer.events = {
	START = 1,
	STOP = 2,
	TIMEOUT = 3,
	EXIT = 4,
}

function STMPeriodicTimer:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(IDLE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function STMPeriodicTimer:timer_stop(timer_no)
	print("Stopping timer.")
	self.scheduler():stop_timer(self.id()..timer_no)
end

function STMPeriodicTimer:timer_start(timer_no)
	local event = Event:new(self.id(), self.events.TIMEOUT)
	local timer = Timer:new(self.id()..timer_no, TIMEOUT_TIME, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMPeriodicTimer:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then

			if event.type() == self.events.START then
				print("Timer started.")
				self:timer_start(T1)
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.EXIT then
				break

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			
			if event.type() == self.events.TIMEOUT and event.timer_id() == T1 then
				print("Tick!")
				self:timer_start(T1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.STOP then
				self:timer_stop(T1)
				self:set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			elseif event.type() == self.events.EXIT then
				break

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMPeriodicTimer