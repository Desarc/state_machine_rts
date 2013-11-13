StateMachine = require "stm"
Timer = require "timer"
Event = require "event"
Message = require "msg"

local DISCONNECTED, CONNECTED = "disconnected", "connected"
local T1 = "t1"
local RECEIVE_INTERVAL = 500*Timer.BASE
local RECEIVE_TIMEOUT = 10*Timer.BASE

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
	local out_data = message.serialize()
	print("Sending data...")
	local res, err = net.send(self.socket, out_data)
	if err ~= 0 then
		return res, err
	end
end


function STMExternalConnection:receive_external()
	local data, err = net.recv(self.socket, "*l", tmr.SYS_TIMER, RECEIVE_TIMEOUT)
	if err ~= 0 then
		return err
	elseif data ~= 0 then
		local message = Message.deserialize(data)
		local event = message.generate_event()
		if event then
			print("Received data request!")
			self.scheduler().add_event(event)
		end
	end
	return false
end

function STMExternalConnection:schedule_receive(timer_no)
	local event = Event:new(self.id(), self.events.RECEIVE_MESSAGE)
	local timer = Timer:new(self.id()..timer_no, RECEIVE_INTERVAL, event)
	event.set_timer_id(timer_no)
	self.scheduler().add_timer(timer)
end

function STMExternalConnection:new(id, scheduler)
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

function STMExternalConnection:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.get_state()

		if current_state == DISCONNECTED then
			
			if event.type() == self.events.CONNECT then
				if self:connect_external() then
					self.set_state(CONNECTED)
					self:schedule_receive(T1)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				
				else
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				end
				
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)	
			end

		elseif current_state == CONNECTED then
			
			if event.type() == self.events.DISCONNECT then
				self:disconnect_external()
				self.set_state(DISCONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.SEND_MESSAGE then
				local message = event.user_data()
				local res, err = self:send_external(message)
				if err then
					print("Sending error: "..res..", terminating system...")
					self.print_error(err)
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				
				else
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event.type() == self.events.RECEIVE_MESSAGE then
				local err = self:receive_external()
				if err == net.ERR_CLOSED or err == net.ERR_ABORTED then
					print("Connection closed.")
					coroutine.yield(StateMachine.TERMINATE_SYSTEM) -- add option to terminate remotely by closing connection
				
				else
					self:schedule_receive()
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

return STMExternalConnection