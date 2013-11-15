local StateMachine = require "stm"
local Timer = require "desktop-timer"
local Event = require "event"
local socket = require "socket"

local CONNECTED, DISCONNECTED, WAITING_DATA = "connected", "disconnected", "waiting_data"
local READ_TIMEOUT = 5000*Timer.BASE
local SEND_TIMEOUT = 5000*Timer.BASE


local STMTcpSocket = StateMachine:new()

STMTcpSocket.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	READ = 3,
	REQUEST = 4,
}

function STMTcpSocket:create_socket()
	print("Creating socket...")
	local server = assert(socket.bind("192.168.100.20", 50001))
	local ip, port = server:getsockname()
	print("Host IP: "..tostring(ip)..", port: "..tostring(port))
	self.client = server:accept()
	print("Connected!")
	local rip, rport = self.client:getpeername()
	print("Client IP: "..tostring(rip)..", port: "..tostring(rport))
	self.client:setoption('keepalive', true)
end

function STMTcpSocket:read_socket()
	print("Waiting for reply...")
	self.client:settimeout(READ_TIMEOUT)
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		if err == 'closed' then
			return false
		end
		return true
	else
		local message = Message.deserialize(line)
		local event = message:generate_event()
		if event then
			print("Data received!")
			self.scheduler().add_event(event)
		end
	end
	return true
end

function STMTcpSocket:send_message(message)
	local data = message.serialize()
	self.client:settimeout(SEND_TIMEOUT)
	local success, err = self.client:send(data)
	if success == nil then
		print(err)
		if err == 'closed' then
			return false
		end
	end
	return true
end

function STMTcpSocket:schedule_read()
	local event = Event:new(self.id(), self.events.READ)
	self.scheduler().add_event(event)
end

function STMTcpSocket:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(DISCONNECTED)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function STMTcpSocket:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == DISCONNECTED then
			
			if event.type() == self.events.CONNECT then
				self:create_socket()
				self:schedule_read()
				self.set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)		
			end
		
		elseif current_state == CONNECTED then

			if event.type() == self.events.REQUEST then
				if self:send_message(event.user_data()) then
					self:schedule_read()
					self.set_state(WAITING_DATA)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self.set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event.type() == self.events.DISCONNECT then
				self.client:close()
				self.set_state(DISCONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)			
			end

		elseif current_state == WAITING_DATA then

			if event.type() == self.events.READ then
				if self:read_socket() then
					self.set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self.set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMTcpSocket