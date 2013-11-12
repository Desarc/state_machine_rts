StateMachine = require "stm"
Timer = require "desktop-timer"
Event = require "event"
Message = require "msg"
STMTcpSocket = require "stm-tcp"

local ACTIVE, IDLE = "active", "idle"
local EVENT_INTERVAL = 1
local SOCKET_ID = "stm_ts1"
local ASSOCIATE_ID = "stm_ql1"
local ASSOCIATE_EVENT = 4 -- STMQueueLength.events.SEND_DATA

STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE_NEW = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMEventGenerator:generate_request()
	print("Requesting readings...")
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT})
	local event = Event:new(SOCKET_ID, STMTcpSocket.events.REQUEST, message)
	self.scheduler:add_to_queue(event)
end

function STMEventGenerator:schedule_self()
	local event = Event:new(self:id(), self.events.GENERATE_NEW)
	self.scheduler:add_timer(Timer:new(EVENT_INTERVAL, self:id(), event))
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif current_state == IDLE then
			
			if event:type() == self.events.START then
				print("Event generator started!")
				self:schedule_self()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			
			if event:type() == self.events.GENERATE_NEW then
				self:generate_request()
				self:schedule_self()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.STOP then
				self:set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMEventGenerator