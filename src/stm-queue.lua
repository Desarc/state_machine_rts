require "stm"
require "timer"
require "event"

local ACTIVE, IDLE = "active", "idle"
local MEASURE_INTERVAL = 100000

STMQueueLength = StateMachine:new()

STMQueueLength.events = {
	START = 1,
	STOP = 2,
	MEASURE = 3,
	EXIT = 4,
}

function STMQueueLength:schedule_measure()
	local event = Event:new(self.data.id, self.events.MEASURE)
	self.scheduler:add_timer(Timer:new(MEASURE_INTERVAL, self.data.id, event))
end

function STMQueueLength:measure()
	local events = self.scheduler:event_queue_length()
	local timers = self.scheduler:timer_queue_length()
	local message = Message:new({events = events, timers = timers})
	local event = Event:new("stm_ec1", 4, message)
	self.scheduler:add_to_queue(event)
end

function STMQueueLength:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMQueueLength:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif current_state == IDLE then
			if event:type() == self.events.START then
				print("Queue length observer started!")
				self:schedule_measure()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			end
		
		elseif current_state == ACTIVE then
			if event:type() == self.events.MEASURE then
				self:measure()
				self:schedule_measure()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				self:set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMQueueLength