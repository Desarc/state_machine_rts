local StateMachine = require "stm"
local Event = require "event"
local Message = require "msg"
local STMTcpClient = require "stm-tcp-client"
local STMPrintMessage = require "stm-print"

local ACTIVE = 1
local EVENT_TARGET = "stm_ts1"
local EVENT_TYPE = STMTcpClient.events.SEND
local ASSOCIATE_ID = "stm_pm1"
local ASSOCIATE_EVENT = STMPrintMessage.events.REQUEST

local STMRequestHandler = StateMachine:new()

STMRequestHandler.events = {
	REQUEST = 1,
}

function STMRequestHandler:handle_request(data)
	print("Received request: "..data)
	local reply = "Hi there."
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT, user_data = reply})
	local event = Event:new(EVENT_TARGET, EVENT_TYPE, message)
	self.scheduler().add_event(event)
	print("Replied: "..reply)
end

function STMRequestHandler:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = ACTIVE}
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
end

function STMRequestHandler:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == ACTIVE then
			if event.type() == self.events.PRINT then
				self:handle_request(event.get_data())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMRequestHandler