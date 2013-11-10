require "state_machine"
require "timer"
require "event"
local socket = require "socket"

local CONNECTED, DISCONNECTED = "Connected", "Disconnected"
local READ_INTERVAL = 0.01


STMTcpSocket = StateMachine:new()

STMTcpSocket.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	READ = 3,
	SEND = 4,
	EXIT = 5,
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
	self.client:settimeout(1)
end

function STMTcpSocket:read_socket()
	--print("Reading socket...")
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		if err == 'closed' then
			return false
		end
		return true
	else	
		print(line)
	end
	return true
end

function STMTcpSocket:send_message(message)
	local data = message:serialize()
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
	local event = Event:new(self.data.id, self.events.READ)
	self.scheduler:add_timer(Timer:new(READ_INTERVAL, self.data.id, event))
end

function STMTcpSocket:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = DISCONNECTED
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTcpSocket:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			self.client:close()
			break

		elseif current_state == DISCONNECTED then
			if event:type() == self.events.CONNECT then
				self:create_socket()
				self:schedule_read()
				self:set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				self.client:close()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			
			end
		
		elseif current_state == CONNECTED then
			if event:type() == self.events.READ then
				if self:read_socket() then
					self:schedule_read()
					self:set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self:set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event:type() == self.events.SEND then
				if self:send_message(event:get_data()) then
					self:set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self:set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event:type() == self.events.DISCONNECT then
				self.client:close()
				self:set_state(DISCONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				self.client:close()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMTcpSocket