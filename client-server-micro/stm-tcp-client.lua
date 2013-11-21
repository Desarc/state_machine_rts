local StateMachine = require "stm"
local Message = require "msg"
local Event = require "event"

local CONNECTED, DISCONNECTED, WAITING_REPLY = 1, 2, 3

local STMTcpClient = StateMachine:new()

STMTcpClient.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	SEND = 3,
	RECEIVE = 4,
}

function STMTcpClient:connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50000

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
		return false
	else
		print("Connected to " .. host_ip_str .. "!")
		self.socket = socket
		return true
	end
end

function STMTcpClient:disconnect()
	net.close(self.socket)
end

function STMTcpClient:receive_reply()
	--print("Waiting for reply...")
	local data, err = net.recv(self.socket, "*l")
	if err ~= 0 then
		return err
	elseif data ~= 0 then
		local message = Message.deserialize(data)
		local event = message.generate_event()
		if event then
			--print("Reply received!")
			self.scheduler().add_event(event)
		end
	end
end

function STMTcpClient:send_request(request)
	local out_data = request.serialize()
	--print("Sending request...")
	local res, err = net.send(self.socket, out_data)
	if err ~= 0 then
		return res, err
	end
end

function STMTcpClient:schedule_receive()
	local event = Event:new(self.id(), self.events.RECEIVE)
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
				self.set_state(WAITING_REPLY)
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