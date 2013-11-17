-- assume modules are loaded my main
--local StateMachine = require "stm"

local INACTIVE, ACTIVE  = "inactive", "active"
local CONN_ID = "stm_ec1"
local CONN_EVENT = STMExternalConnection.events.SEND_MESSAGE
local msg_size = 400

local STMSendMessage = StateMachine:new()

STMSendMessage.events = {
	START = 1,
	SEND = 2,
}

function STMSendMessage:schedule_self(event)
	event = self:create_event(event, self:id(), self.events.SEND)
	self.scheduler:add_event(event)
end

function STMSendMessage:send_message(event)
	local msg = {}
	for i=1,msg_size do
		msg[i] = "a"
	end
	table.insert(msg, "\n")
	local message = Message:new({user_data = table.concat(msg, "")})
	local event = self:create_event(event, CONN_ID, CONN_EVENT, message)
	self.scheduler:add_event(event)
end

function STMSendMessage:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMSendMessage:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == INACTIVE then
			if event:type() == self.events.START then
				print("STMSendMessage started.")
				self:schedule_self(event)
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.SEND then
				self:send_message(nil)
				self:schedule_self(event)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMSendMessage