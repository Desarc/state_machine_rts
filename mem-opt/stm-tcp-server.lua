local Socket = require "socket"

local CONNECTED, DISCONNECTED = 1, 2

STMTcpServer = StateMachine:new()

STMTcpServer.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	RECEIVE = 3,
	SEND = 4,
}

function STMTcpServer:connect()
	local server = assert(Socket.bind("192.168.100.20", 50000))
	local ip, port = server:getsockname()
	print("Host IP: "..tostring(ip)..", port: "..tostring(port))
	self.client = server:accept()
	print("Connected!")
	local rip, rport = self.client:getpeername()
	print("Client IP: "..tostring(rip)..", port: "..tostring(rport))
	self.client:setoption('keepalive', true)
end

function STMTcpServer:disconnect()
	self.client:close()
end

function STMTcpServer:receive_request()
	--print("Waiting for request...")
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		return false
	else
		local message = Message.deserialize(line)
		local event = message:generate_event()
		if event then
			--print("Request received!")
			self.scheduler:add_event(event)
		end
		return true
	end
end

function STMTcpServer:send_reply(reply)
	--print("Sending reply...")
	local out_data = reply:serialize()
	local success, err = self.client:send(out_data)
	if success == nil then
		print(err)
		return err
	else
		return nil
	end
end

function STMTcpServer:schedule_receive(event)
	event = self.create_event(event, self.id, self.events.RECEIVE)
	self.scheduler:add_event(event)
end

function STMTcpServer:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.id = id
	o.state = DISCONNECTED
	self.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTcpServer:fire()
	while(true) do
		local event = self.scheduler.active_event

		if self.state == DISCONNECTED then
			
			if event.type == self.events.CONNECT then
				self:connect()
				self:schedule_receive(event)
				self.state = CONNECTED
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)		
			end
		
		elseif self.state == CONNECTED then

			if event.type == self.events.RECEIVE then
				self:receive_request()
				self:schedule_receive(event)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type == self.events.DISCONNECT then
				self:disconnect()
				self.state = DISCONNECTED
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)			
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end