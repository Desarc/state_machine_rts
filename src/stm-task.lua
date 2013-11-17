-- assume modules are loaded my main
--local StateMachine = require "stm"

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local EVENT_INTERVAL = 1*Timer.BASE
local task_size = 50000
local CONN_ID = "stm_ec1"
local CONN_EVENT = STMExternalConnection.events.SEND_MESSAGE
local send_counter = 100

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end


local STMSimpleTask = StateMachine:new()

STMSimpleTask.events = {
	START = 1,
	RUN_TASK = 2,
}

function STMSimpleTask:schedule_self(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.RUN_TASK)
	timer = self:set_timer(timer, self:id()..timer_no, EVENT_INTERVAL, event)
	event:set_timer(timer)
end

function STMSimpleTask:send_data(event)
	local now = self.scheduler.time()
	local delta = now - self.previous
	self.previous = now
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = delta})
	local event = self:create_event(event, CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
end

function STMSimpleTask:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMSimpleTask:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()


		if current_state == INACTIVE then
			if event:type() == self.events.START then
				self.previous = self.scheduler.time()
				self:schedule_self(T1, event, event:timer())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.RUN_TASK then
				simple_task()
				self:send_data(nil)
				self:schedule_self(T1, event, event:timer())
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