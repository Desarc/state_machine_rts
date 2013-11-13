StateMachine = require "stm"

local ACTIVE  = "active"
local task_size = 5000

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end


STMSimpleTask = StateMachine:new()

STMSimpleTask.events = {
	RUN_TASK = 1,
}

function STMSimpleTask:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(ACTIVE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function STMSimpleTask:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.get_state()

		if current_state == ACTIVE then
			if event.type() == self.events.RUN_TASK then
				simple_task()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMSimpleTask