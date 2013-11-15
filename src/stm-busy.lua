local StateMachine = require "stm"
local Event = require "event"

local IDLE, WORKING  = "idle", "working"
local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local task_repeats = {1, 50, 100, 500}
local runs = 10

local current_size = task_sizes[1]
local current_repeats = task_repeats[1]

local function busy_work()
	for i=1,current_size do
		q = i*i
	end
end

local STMBusyWork = StateMachine:new()

STMBusyWork.events = {
	START = 1,
	DO_WORK = 2,
	STOP = 3, 
}

function STMBusyWork:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(IDLE)
	o.scheduler = function ()
		return sched
	end
	o.current_size_count = 1
	o.current_repeats_count = 1
	o.repeat_count = 0
	o.run_count = 0
	o.total_count = 0
	o.time = {}
	scheduler.add_state_machine(o)
	return o
end

function STMBusyWork:average()
	local sum = 0
	local count = 0
	for k,v in ipairs(self.time) do
		sum = sum + v
		count = count + 1
	end
	local average = sum/count
	return average
end

function STMBusyWork:schedule_self()
	local event = Event:new(self.id(), self.events.DO_WORK)
	self.scheduler().add_event(event)
end

function STMBusyWork:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then
			if event.type() == self.events.START then
				self:schedule_self()
				self.start = self.scheduler().time()
				self.set_state(WORKING)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == WORKING then
			if event.type() == self.events.DO_WORK then
				if self.repeat_count < current_repeats then
					busy_work()
					self.repeat_count = self.repeat_count + 1
					self:schedule_self()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)

				else
					local delta = self.scheduler().time() - self.start
					--print("Delta: "..tostring(delta))
					table.insert(self.time, delta)
					self.run_count = self.run_count + 1
					if self.run_count < runs then
						self.repeat_count = 0
						self:schedule_self()
						self.start = self.scheduler().time()
						coroutine.yield(StateMachine.EXECUTE_TRANSITION)

					elseif self.total_count < table.getn(task_sizes)*table.getn(task_repeats) then
						print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(self:average()))
						self.time = {}
						if self.current_size_count >= table.getn(task_sizes) then
							self.current_size_count = 1
							if self.current_repeats_count >= table.getn(task_repeats) then
								self.current_repeats_count = 1
							else
								self.current_repeats_count = self.current_repeats_count + 1
							end
						else
							self.current_size_count = self.current_size_count + 1
						end
						current_size = task_sizes[self.current_size_count]
						current_repeats = task_repeats[self.current_repeats_count]
						self.run_count = 0
						self.total_count = self.total_count + 1
						self:schedule_self()
						self.start = self.scheduler().time()
						coroutine.yield(StateMachine.EXECUTE_TRANSITION)

					else
						coroutine.yield(StateMachine.TERMINATE_SYSTEM)
					end
				end
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMBusyWork