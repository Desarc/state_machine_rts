require "state_machine"
require "timer"
require "event"
require "message"

local ACTIVE, IDLE = "Active", "Idle"
local EVENT_INTERVAL = 1

local function generator_start()
	print("Event generator started!")
end

STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE_NEW = 3,
	EXIT = 4,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	o.count = 0
	return o
end

function STMEventGenerator:generate_event()
	local message = Message:new({stm_id = "stm_c1", event_type = 1})
	local event = Event:new("stm_ts1", 4, message)
	self.scheduler:add_to_queue(event)
	self.count = self.count + 1
	print("Total count should now be "..self.count)
end

function STMEventGenerator:generate_request()
	local message = Message:new({stm_id = "stm_c1", event_type = 1})
	local event = Event:new("stm_ts1", 4, message)
	self.scheduler:add_to_queue(event)
	print("Requesting readings...")
end

function STMEventGenerator:schedule_self()
	local event = Event:new(self.data.id, self.events.GENERATE_NEW)
	self.scheduler:add_timer(Timer:new(EVENT_INTERVAL, self.data.id, event))
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif current_state == IDLE then
			if event:type() == self.events.START then
				generator_start()
				self:schedule_self()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			end
		
		elseif current_state == ACTIVE then
			if event:type() == self.events.GENERATE_NEW then
				self:generate_event()
				self:schedule_self()
				self:set_state(ACTIVE)
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

return STMEventGenerator