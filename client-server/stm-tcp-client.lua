local StateMachine = require "stm"
local Message = require "msg"
local Event = require "event"
local Socket = require "socket"

local CONNECTED, DISCONNECTED, WAITING_REPLY = "connected", "disconnected", "waiting_reply"
local READ_TIMEOUT = nil
--local READ_TIMEOUT = 10000*Timer.BASE
local SEND_TIMEOUT = 10000*Timer.BASE


local STMTcpClient = StateMachine:new()

STMTcpClient.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	SEND = 3,
	RECEIVE = 4,
}

function STMTcpClient:create_socket()
	print("Creating socket...")
	local server = assert(Socket.bind("192.168.100.20", 50001))
	local ip, port = server:getsockname()
	print("Host IP: "..tostring(ip)..", port: "..tostring(port))
	self.client = server:accept()
	print("Connected!")
	local rip, rport = self.client:getpeername()
	print("Client IP: "..tostring(rip)..", port: "..tostring(rport))
	self.client:setoption('keepalive', true)
end

function STMTcpClient:read_socket()
	self.client:settimeout(READ_TIMEOUT)
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		return false
	else
		local message = Message.deserialize(line)
		local event = message:generate_event()
		if event then
			print("Reply received!")
			self.scheduler:add_event(event)
		end
		return true
	end
end

function STMTcpClient:send_message(message)
	local data = message:serialize()
	self.client:settimeout(SEND_TIMEOUT)
	local success, err = self.client:send(data)
	if success == nil then
		print(err)
		return err
	else
		return nil
	end
end

function STMEventGenerator:schedule_event()
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
				self:create_socket()
				self.set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)		
			end
		
		elseif current_state == CONNECTED then

			if event.type() == self.events.SEND then
				local err = self:send_message(event.get_data())
				if err == nil then
					self.set_state(WAITING_REPLY)
					self:schedule_receive()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)

				else
					self.client:close()
					self.set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)			
			end

		elseif current_state == WAITING_REPLY then

			if event.type() == self.events.RECEIVE then
				if self:read_socket() then
					self.set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self.set_state(DISCONNECTED)
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				end
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMTcpClient