STMTimeMeasure = StateMachine:new()

local INACTIVE, ACTIVE  = "inactive", "active"
local T1 = "t1"
local MEASURE_INTERVAL = 10*Timer.BASE
local ASSOCIATE_ID = "stm_l1"
local ASSOCIATE_EVENT = 2 -- STMLogger.events.LOG
local CONN_ID = "stm_ec1"
local CONN_EVENT = STMExternalConnection.events.SEND_MESSAGE

STMTimeMeasure.events = {
	START = 1,
	SET_EVENT = 2, 
	MEASURE = 3,
}

function STMTimeMeasure:schedule_self(timer_no, event, timer)
	event = self:create_event(event, self:id(), self.events.SET_EVENT)
	timer = self:set_timer(timer, self:id()..timer_no, MEASURE_INTERVAL, event)
	event:set_timer(timer)
end

function STMTimeMeasure:set_event(event)
	event = self:create_event(event, self:id(), self.events.MEASURE)
	self.scheduler:add_event(event)
end

function STMTimeMeasure:send_data(event)
	local now = self.scheduler.time()
	local delta = now - self.previous
	local queue = self.scheduler:event_queue_length()
	self.previous = now
	local mem = collectgarbage("count")
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = delta.." "..queue})
	local event = self:create_event(event, CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
end

function STMTimeMeasure:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTimeMeasure:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == INACTIVE then
			if event:type() == self.events.START then
				print("Time measure started.")
				self.previous = self.scheduler.time()
				self:schedule_self(T1, event, event:timer())
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.MEASURE then
				self:send_data(event)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.SET_EVENT then
				self:schedule_self(T1, event, event:timer())
				self:set_event(nil)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMTimeMeasure