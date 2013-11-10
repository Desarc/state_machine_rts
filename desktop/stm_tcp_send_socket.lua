require "state_machine"
require "timer"
require "event"
local socket = require "socket"

local CONNECTED, DISCONNECTED = "Connected", "Disconnected"
local SEND_INTERVAL = 0.01


STMTcpSendSocket = StateMachine:new()

STMTcpSendSocket.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	SEND = 3,
	EXIT = 4,
}

function STMTcpSendSocket:connect_socket()
	print("Attempting to connect...")
	self.client = socket.connect("127.0.0.1", 50001)
	print("Connected!")
	local rip, rport = self.client:getpeername()
	print("Server IP: "..tostring(rip)..", port: "..tostring(rport))
	self.client:setoption('keepalive', true)
end

function  STMTcpSendSocket:send_message(message)
	print("Sending message...")
	local success, err = self.client:send(message..'\n')
	if success == nil then
		print(err)
		if err == 'closed' then
			return false
		end
	end
	return true
end

function STMTcpSendSocket:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = DISCONNECTED
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTcpSendSocket:fire()
	while(true) do
		local event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			self.client:close()
			break

		elseif self.data.current_state == DISCONNECTED then
			if event:type() == self.events.CONNECT then
				self:connect_socket()
				local event = Event:new(self.data.id, self.events.SEND)
				local timer = Timer:new(self.scheduler.time()+SEND_INTERVAL, self.data.id, event)
				self.scheduler:add_timer(timer)
				self.data.current_state = CONNECTED
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				self.client:close()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			
			end
		
		elseif self.data.current_state == CONNECTED then
			if event:type() == self.events.SEND then
				if self:send_message('ping') then
					local event = Event:new(self.data.id, self.events.SEND)
					self.scheduler:add_timer(Timer:new(self.scheduler.time()+SEND_INTERVAL, self.data.id, event))
					self.data.current_state = CONNECTED
				else
					self.client:close()
					self.data.current_state = DISCONNECTED
				end
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

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

return STMTcpSendSocket