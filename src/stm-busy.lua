StateMachine = require "stm"

local WORKING  = "working"
local task_size = 50000
local task_repeats = 500
local runs = 5

local function busy_work()
	for i=1,task_size do
		q = i*i
	end
end

STMBusyWork = StateMachine:new()

STMBusyWork.events = {
	DO_WORK = 1,
}

function STMBusyWork:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = WORKING
	o.scheduler = scheduler
	o.repeat_count = 0
	o.run_count = 0
	o.start = scheduler.time()
	scheduler:add_state_machine(o)
	return o
end

function STMBusyWork:schedule_self()
	local event = Event:new(self:id(), self.events.DO_WORK)
	self.scheduler:add_to_queue(event)
end

function STMBusyWork:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if current_state == WORKING then
			if event:type() == self.events.DO_WORK then
				if self.repeat_count < task_repeats then
					busy_work()
					self.repeat_count = self.repeat_count + 1
					self:schedule_self()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)

				else
					self.run_count = self.run_count + 1
					local delta = self.scheduler.time() - self.start
					print("Delta: "..tostring(delta))
					if self.run_count < runs then
						self.repeat_count = 0
						self:schedule_self()
						self.start = self.scheduler.time()
						coroutine.yield(StateMachine.EXECUTE_TRANSITION)

					else
						coroutine.yield(StateMachine.TERMINATE_SYSTEM)
					end
				end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)

		end
	end
end

return STMBusyWork