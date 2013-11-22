local StateMachine = require "stm"
local Event = require "event"

local STMPerformanceTester = StateMachine:new()

local IDLE, TESTING  = 1, 2
local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local task_repeats = {1, 50, 100, 500}
--local task_repeats = {1}
local runs = 10

local current_size = task_sizes[1]
local current_repeats = task_repeats[1]

local function simple_task()
	for i=1,current_size do
		q = i*i
	end
end

STMPerformanceTester.events = {
	START = 1,
	TEST = 2,
	STOP = 3, 
}

function STMPerformanceTester:new(id, scheduler)
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
	
	o.current_size_count = 1
	o.current_repeats_count = 1
	o.repeat_count = 0
	o.run_count = 0
	o.total_count = 0
	o.time = {}

	scheduler.add_state_machine(o)
	return o
end

function STMPerformanceTester:average()
	local sum = 0
	local count = 0
	for k,v in ipairs(self.time) do
		sum = sum + v
		count = k
	end
	local average = sum/count
	return average
end

function STMPerformanceTester:schedule_self()
	local event = Event:new(self.id(), self.events.TEST)
	self.scheduler().add_event(event)
end

function STMPerformanceTester:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then
			if event.type() == self.events.START then
				print("Running performance tests...")
				self:schedule_self()
				self.start = self.scheduler().time()
				self.set_state(TESTING)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == TESTING then
			if event.type() == self.events.TEST then
				if self.repeat_count < current_repeats then
					simple_task()
					self.repeat_count = self.repeat_count + 1
					self:schedule_self()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)

				else
					local delta = self.scheduler().time() - self.start
					table.insert(self.time, delta)
					self.run_count = self.run_count + 1
					if self.run_count < runs then
						self.repeat_count = 0
						self:schedule_self()
						self.start = self.scheduler().time()
						coroutine.yield(StateMachine.EXECUTE_TRANSITION)

					elseif self.total_count < table.getn(task_sizes)*table.getn(task_repeats) then
						print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(self:average()))
						for i in ipairs(self.time) do
							self.time[i] = nil
						end
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

return STMPerformanceTester