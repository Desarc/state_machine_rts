local StateMachine = require "stm"
local Timer = require "desktop-timer"
local Event = require "event"
local Message = require "msg"
local STMTcpSocket = require "stm-tcp"
local STMQueueLength = require "stm-queue"

local ACTIVE, IDLE = "active", "idle"
local T1 = "t1"
local EVENT_INTERVAL = 1000*Timer.BASE
local SOCKET_ID = "stm_ts1"
local ASSOCIATE_ID = "stm_ql1"

local STMEventGenerator = StateMachine:new()

STMEventGenerator.events = {
	START = 1,
	STOP = 2,
	GENERATE_NEW = 3,
}

function STMEventGenerator:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(IDLE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function STMEventGenerator:generate_request()
	print("Requesting readings...")
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = STMQueueLength.events.SEND_DATA})
	local event = Event:new(SOCKET_ID, STMTcpSocket.events.REQUEST, message)
	self.scheduler().add_event(event)
end

function STMEventGenerator:schedule_self(timer_no)
	local event = Event:new(self.id(), self.events.GENERATE_NEW)
	local timer = Timer:new(self.id()..timer_no, EVENT_INTERVAL, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMEventGenerator:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == IDLE then
			
			if event.type() == self.events.START then
				print("Event generator started!")
				self:schedule_self(T1)
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		elseif current_state == ACTIVE then
			
			if event.type() == self.events.GENERATE_NEW then
				self:generate_request()
				self:schedule_self(T1)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.STOP then
				self.set_state(IDLE)
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