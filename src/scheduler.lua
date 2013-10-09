Scheduler = {}

function Scheduler:add_state_machine(state_machine)
	-- create a coroutine to resume when calling <state_machine>.run()
	-- the coroutine should call the <state_machine>:fire() function when resumed 
	state_machine.run = coroutine.create(state_machine.fire)
	-- index by ID (must be unique)
	self.state_machine_list[state_machine:id()] = state_machine
	print("State machine '"..state_machine:id().."' added to scheduler.")
end

function Scheduler:remove_state_machine(state_machine)
	if self.state_machine_list[state_machine:id()] then
		result = true -- return true if state machine existed
		print("State machine '"..state_machine:id().."' removed from scheduler.")
	end
	self.state_machine_list[state_machine:id()] = nil
	return result
end

function Scheduler:add_to_queue(event)
	table.insert(self.event_queue, event)
end

function Scheduler:get_next_event()
	return table.remove(self.event_queue, 1)
end

local function decode_message(message)
	-- search for delimiter
	local delim1 = string.find(message, ";")
	local state_machine_id = string.sub(message, 1, delim1-1)
	local delim2 = string.find(message, ";", delim1+1)
	local type = 0
	local user_data = nil
	if delim2 ~= nil then
		type = tonumber(string.sub(message, delim1+1, delim2-1))
		user_data = string.sub(message, delim2+1)
	else
		type = tonumber(string.sub(message, delim1+1))
	end
	local event = Event:new(state_machine_id, type, user_data)
	return event
end

function Scheduler:connect_external()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50001

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
	else
		print("Connected to " .. host_ip_str .. "!")
	end
	self.socket = socket
end

function Scheduler:receive_external()
	local data, err = net.recv(self.socket, "*l", 0)
	if err ~= 0 then
		print("Receive error: " .. err)
		return true
	elseif data ~= 0 then
		if data == "terminate" then
			return true
		end
		local event = decode_message(data)
		self:add_to_queue(event)
		print("External event received!")
		--print("Addr: "..tostring(event:state_machine_id()))
		--print("Type: "..tostring(event:type()))
		--print("User data: "..tostring(event:get_data()))
	end
	return false
end



function Scheduler.time()
	return tmr.read(tmr.SYS_TIMER)
end

local function timers_cmp(t1, t2)
	if t1:expires() < t2:expires() then return true end
end

-- add timer to list based on expiry time
function Scheduler:add_timer(timer)
	if timer:expires() then
		table.insert(self.timers, timer)
		table.sort(self.timers, timers_cmp)
	end
end

function Scheduler:stop_timer(id)
	for k, v in self.timers do
		if v:id() == id then
			table.remove(self.timers, k)
			break
		end
	end
end

-- TODO: better precision on timer check
function Scheduler:check_timers()
	local now = self.time()
	if self.timers[1] then
		if self.timers[1]:expires() < now then return table.remove(self.timers, 1) end
	end
end

function Scheduler:set_active_event(event)
	self.active_event = event
end

function Scheduler:get_active_event()
	local event = self.active_event
	self.active_event = nil
	return event
end

function Scheduler:check_active()
	if table.getn(self.timers) > 0 or table.getn(self.event_queue) > 0 then
		return true
	else
		return false
	end
end

function Scheduler:run()
	print("Scheduler running.")
	self:connect_external()
	-- TODO: passive waiting if no events/timers?
	local success, status, state_machine
	local terminate = false

	while(not terminate) do
		
		local timer = self:check_timers()
		if timer then
			--print("Timer expired!")
			state_machine = self.state_machine_list[timer:state_machine_id()]
			self:set_active_event(timer:event())
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self:remove_state_machine(state_machine)
			end
		end

		local event = self:get_next_event()
		if event then
			--print("Event received!")
			state_machine = self.state_machine_list[event:state_machine_id()]
			self:set_active_event(event)
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self:remove_state_machine(state_machine)
			end
		end
		terminate = self:receive_external()
	end
	print("Received exteral command to terminate...")
end


function Scheduler:new()
	o = {}
	setmetatable(o, { __index = self })
	o.state_machine_list = {}
	o.event_queue = {}
	o.timers = {}
	return o
end


return Scheduler