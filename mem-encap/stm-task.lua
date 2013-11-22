local Event = require "event"
local Timer = require "timer"
local StateMachine = require "stm"

local STMSimpleTask = StateMachine:new()

local IDLE, ACTIVE  = 1, 2
local T1 = "t1"
local EVENT_INTERVAL = 10*Timer.BASE
local task_size = 500

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end

STMSimpleTask.events = {
	START = 1,
	RUN_TASK = 2,
}

function STMSimpleTask:schedule_self(timer_no)
	local event = Event:new(self.id(), self.events.RUN_TASK)
	local timer = Timer:new(self.id()..timer_no, EVENT_INTERVAL, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMSimpleTask:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = IDLE}
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

function STMSimpleTask:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then
			if event.type() == self.events.START then
				self:schedule_self(T1)
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event.type() == self.events.RUN_TASK then
				simple_task()
				self:schedule_self(T1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMSimpleTask