STMSimpleTask = StateMachine:new()

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

function STMSimpleTask:schedule_self(timer_no, event, timer)
	event = self.create_event(event, self.id, self.events.RUN_TASK)
	timer = self.create_timer(timer, self.id..timer_no, EVENT_INTERVAL, event)
	event.timer = timer
	self.scheduler:add_timer(timer)
end

function STMSimpleTask:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.id = id
	o.state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMSimpleTask:fire()
	while(true) do
		local event = self.scheduler.active_event

		if self.state == INACTIVE then
			if event.type == self.events.START then
				self:schedule_self(T1, event, event.timer)
				self.state = ACTIVE
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif self.state == ACTIVE then
			if event.type == self.events.RUN_TASK then
				simple_task()
				self:schedule_self(T1, event, event.timer)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end