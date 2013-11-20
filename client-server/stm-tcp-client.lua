local StateMachine = require "stm"
local Message = require "msg"
local Event = require "event"
local Socket = require "socket"

local CONNECTED, DISCONNECTED, WAITING_REPLY = 1, 2, 3

local STMTcpClient = StateMachine:new()

STMTcpClient.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	SEND = 3,
	RECEIVE = 4,
}

function STMTcpClient:connect()
	self.client = Socket.tcp()
	assert(self.client:connect("127.0.0.1", 50000))
	local ip, port = self.client:getsockname()
	print("Connected!")
	print("Client IP: "..tostring(ip)..", port: "..tostring(port))
	local rip, rport = self.client:getpeername()
	print("Host IP: "..tostring(rip)..", port: "..tostring(rport))
	self.client:setoption('keepalive', true)
end

function STMTcpClient:disconnect()
	self.client:close()
end

function STMTcpClient:receive_reply()
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		return false
	else
		local message = Message.deserialize(line)
		local event = message.generate_event()
		if event then
			print("Reply received!")
			self.scheduler().add_event(event)
		end
		return true
	end
end

function STMTcpClient:send_request(request)
	local out_data = request.serialize()
	local success, err = self.client:send(out_data)
	if success == nil then
		print(err)
		return err
	else
		return nil
	end
end

function STMTcpClient:schedule_receive()
	local event = Event:new(event, self.id(), self.events.RECEIVE)
	self.scheduler().add_event(event)
end

function STMTcpClient:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = DISCONNECTED}
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

function STMTcpClient:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == DISCONNECTED then
			
			if event.type() == self.events.CONNECT then
				self:connect()
				self.set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)		
			end
		
		elseif current_state == CONNECTED then

			if event.type() == self.events.SEND then
				self:send_request(event.get_data())
				self:schedule_receive()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.DISCONNECT then
				self:disconnect()
				self.set_state(DISCONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)			
			end

		elseif current_state == WAITING_REPLY then

			if event.type() == self.events.RECEIVE then
				self:receive_reply()
				self.set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMTcpClient