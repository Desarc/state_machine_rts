require "stm"
require "timer"
require "event"
require "msg"

local DISCONNECTED, CONNECTED = "disconnected", "connected"
local RECEIVE_DELAY = 5000

STMExternalConnection = StateMachine:new()

STMExternalConnection.events = {
	CONNECT = 1,
	DISCONNECT = 2,
	RECEIVE_MESSAGE = 3,
	SEND_MESSAGE = 4,
}

function STMExternalConnection.print_error(err_code)
	if err_code == net.ERR_TIMEOUT then
		print("Connection timed out.")
	elseif err_code == net.ERR_CLOSED then
		print("Connection is closed.")
	elseif err_code == net.ERR_ABORTED then
		print("Connection aborted.")
	elseif err_code == net.ERR_OVERFLOW then
		print("Buffer overflow!")
	elseif err_code == net.ERR_OK then
		print("Connection is OK!")
	end	
end

function STMExternalConnection:connect_external()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50001

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
		self.print_error(err)
		return false
	else
		print("Connected to " .. host_ip_str .. "!")
		self.socket = socket
		return true
	end
end


function STMExternalConnection:send_external(message)
	-- buffer any data waiting...
	local in_data, err = net.recv(self.socket, "*l", tmr.SYS_TIMER, 100000) -- timeout must be long enough to receive a waiting message
	if in_data then
		print("data: "..tostring(in_data)..", err: "..tostring(err))
		local message = Message.deserialize(in_data)
		local event = message:generate_event()
		if event then
			self.scheduler:add_to_queue(event)
		end
	end
	local out_data = message:serialize()
	print("Sending message: "..out_data)
	res, err = net.send(self.socket, out_data)
	if err ~= 0 then
		return res, err
	end
end


function STMExternalConnection:receive_external()
	--print("Reading socket...")
	local data, err = net.recv(self.socket, "*l", tmr.SYS_TIMER, 100000)
	--print("data: "..tostring(data)..", err: "..tostring(err))
	if err ~= 0 then
		self.print_error(err)
		return err
	elseif data ~= 0 then
		--print("External message received!")
		if data == "terminate" then
			return data
		end
		local message = Message.deserialize(data)
		local event = message:generate_event()
		if event then
			self.scheduler:add_to_queue(event)
		end
	end
	return false
end

function STMExternalConnection:schedule_receive()
	local event = Event:new(self:id(), self.events.RECEIVE_MESSAGE)
	self.scheduler:add_timer(Timer:new(RECEIVE_DELAY, self:id(), event))
end

function STMExternalConnection:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self})
	o.data = {}
	o.data.id = id
	o.data.current_state = DISCONNECTED
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMExternalConnection:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break
		elseif current_state == DISCONNECTED then
			if event:type() == self.events.CONNECT then
				if self:connect_external() then
					self:set_state(CONNECTED)
					--self:schedule_receive()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					coroutine.yield(StateMachine.TERMINATE_SYSTEM) -- add option to terminate remotely
				end
				
			else
				print("Invalid event for this state.")
				print("State: "..tostring(current_state))
				print(event:to_string())
				coroutine.yield(StateMachine.DISCARD_EVENT)	
			end
		elseif current_state == CONNECTED then
			if event:type() == self.events.DISCONNECT then
				self:disconnect_external()
				self:set_state(DISCONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.SEND_MESSAGE then
				local message = event:get_data()
				res, err = self:send_external(message)
				if err then
					print("Sending error: "..res..", terminating system...")
					self.print_error(err)
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				else
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event:type() == self.events.RECEIVE_MESSAGE then
				local err = self:receive_external()
				if err == "terminate" then
					coroutine.yield(StateMachine.TERMINATE_SYSTEM) -- add option to terminate remotely
				
				elseif err == net.ERR_CLOSED or err == net.ERR_ABORTED then
					print("Connection closed.")
					coroutine.yield(StateMachine.TERMINATE_SYSTEM) -- add option to terminate remotely
				
				else
					self:schedule_receive()
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end
			else
				print("Invalid event for this state.")
				print("State: "..tostring(current_state))
				print(event:to_string())
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		else
			print("Invalid state.")
			print(event:to_string())
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return STMExternalConnection