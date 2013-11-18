local StateMachine = require "stm"
local Timer = require "desktop-timer"
local Event = require "event"
local Message = require "msg"
local socket = require "socket"
--local STMQueueLength = require "stm-queue"

local CONNECTED, DISCONNECTED, WAITING_DATA = "connected", "disconnected", "waiting_data"
local T1 = "t1"
local REQUEST_INTERVAL = 10000*Timer.BASE
local READ_TIMEOUT = nil
--local READ_TIMEOUT = 10000*Timer.BASE
local SEND_TIMEOUT = 10000*Timer.BASE
--local ASSOCIATE_ID = "stm_ql1"
--local ASSOCIATE_EVENT = STMQueueLength.events.SEND_DATA


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
	print("Waiting for readings...")
	self.client:settimeout(READ_TIMEOUT)
	local line, err = self.client:receive('*l')
	if line == nil then
		print(err)
		return false
	else
		print(line)
		local message = Message.deserialize(line)
		local event = message:generate_event()
		if event then
			print("Data received!")
			self.scheduler:add_event(event)
		end
		return true
	end
end

function STMTcpSocket:send_message(message)
	print("Requesting readings...")
	local data = message:serialize()
	self.client:settimeout(SEND_TIMEOUT)
	local success, err = self.client:send(data)
	print(success)
	print(err)
	if success == nil then
		print(err)
		return err
	else
		return nil
	end
end

function STMTcpSocket:schedule_read(event)
	event = self:create_event(event, self:id(), self.events.READ)
	self.scheduler:add_event(event)
end

function STMTcpSocket:schedule_request(timer_no, event, timer)
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT})
	event = self:create_event(event, self:id(), self.events.REQUEST, message)
	timer = self:set_timer(timer, self:id()..timer_no, REQUEST_INTERVAL, event)
	event:set_timer(timer)
end

function STMTcpSocket:reschedule_request(event)
	local message = Message:new({stm_id = ASSOCIATE_ID, event_type = ASSOCIATE_EVENT})
	event = self:create_event(event, self:id(), self.events.REQUEST, message)
	self.scheduler:add_event(event)
end

function STMTcpSocket:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = DISCONNECTED}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMTcpSocket:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == DISCONNECTED then
			
			if event:type() == self.events.CONNECT then
				self:create_socket()
				self:schedule_read(event)
				--self:schedule_request(T1, event, event:timer())
				self:set_state(CONNECTED)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)		
			end
		
		elseif current_state == CONNECTED then

			if event:type() == self.events.REQUEST then
				local err = self:send_message(event:get_data())
				if err == nil then
					self:schedule_read(event)
					self:set_state(WAITING_DATA)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				elseif err == 'timeout' then
					self:reschedule_request(event)
				else
					self.client:close()
					self:set_state(DISCONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				end

			elseif event:type() == self.events.READ then
				if self:read_socket() then
					self:schedule_read(event)
					self:set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self:set_state(DISCONNECTED)
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				end

			elseif event:type() == self.events.DISCONNECT then
				self.client:close()
				self:set_state(DISCONNECTED)
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)			
			end

		elseif current_state == WAITING_DATA then

			if event:type() == self.events.READ then
				if self:read_socket() then
					self:schedule_request(T1, event, event:timer())
					self:set_state(CONNECTED)
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					self.client:close()
					self:set_state(DISCONNECTED)
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

return STMTcpSocket