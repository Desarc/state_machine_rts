require "state_machine"
require "timer"
require "event"
local socket = require "socket"

local CONNECTED, DISCONNECTED = "Connected", "Disconnected"
local READ_INTERVAL = 0.01


STMTcpReceiveSocket = StateMachine:new()

STMTcpReceiveSocket.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	READ = 3,
	EXIT = 4,
}

function STMTcpReceiveSocket:create_socket()
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

function STMTcpReceiveSocket:read_socket()
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

function STMTcpReceiveSocket:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = DISCONNECTED
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTcpReceiveSocket:fire()
	while(true) do
		local event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			self.client:close()
			break

		elseif self.data.current_state == DISCONNECTED then
			if event:type() == self.events.CONNECT then
				self:create_socket()
				local event = Event:new(self.data.id, self.events.READ)
				local timer = Timer:new(self.scheduler.time()+READ_INTERVAL, self.data.id, event)
				self.scheduler:add_timer(timer)
				self.data.current_state = CONNECTED
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				self.client:close()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			
			end
		
		elseif self.data.current_state == CONNECTED then
			if event:type() == self.events.READ then
				if self:read_socket() then
					local event = Event:new(self.data.id, self.events.READ)
					self.scheduler:add_timer(Timer:new(self.scheduler.time()+READ_INTERVAL, self.data.id, event))
					self.data.current_state = CONNECTED
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self.data.current_state = DISCONNECTED
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end
				

			elseif event:type() == self.events.DISCONNECT then
				self.client:close()
				self.data.current_state = DISCONNECTED
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

return STMTcpReceiveSocket