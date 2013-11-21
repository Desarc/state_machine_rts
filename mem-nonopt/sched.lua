local DESKTOP_TIMEOUT = 10e10*Timer.BASE
local CONTROLLER_TIMEOUT = 300000*Timer.BASE

local function controller_time()
	return tmr.read(tmr.SYS_TIMER)
end

local function desktop_time()
	return os.time()
end

Scheduler = {}

Scheduler.type = {
	DESKTOP = 1,
	CONTROLLER = 2,
}

function Scheduler:add_state_machine(state_machine)
	state_machine.run = coroutine.create(state_machine.fire)
	self.state_machine_list[state_machine:id()] = state_machine
	print("State machine '"..state_machine:id().."' added to scheduler.")
end

function Scheduler:remove_state_machine(id)
	if self.state_machine_list[id] then
		result = true
		print("State machine '"..id.."' removed from scheduler.")
	end
	self.state_machine_list[id] = nil
	return result
end

function Scheduler:add_event(event)
	table.insert(self.event_queue, event)
end

function Scheduler:check_events()
	if self.event_queue[1] then return true
	else return false end
end

function Scheduler:get_next_event()
	return table.remove(self.event_queue, 1)
end

function Scheduler:event_queue_length()
	return table.getn(self.event_queue)
end

function Scheduler:timer_queue_length()
	return table.getn(self.timer_queue)
end

local function timers_cmp(t1, t2)
	if t1:expires() < t2:expires() then return true end
end

function Scheduler:add_timer(timer)
	if timer:expires() then
		table.insert(self.timer_queue, timer)
		table.sort(self.timer_queue, timers_cmp)
	end
end

function Scheduler:stop_timer(id)
	for k, v in pairs(self.timers) do
		if v:id() == id then
			table.remove(self.timers, k)
			break
		end
	end
end

function Scheduler:check_timers()
	local now = self.time()
	if self.timer_queue[1] then
		if self.timer_queue[1]:expires() < now then return true end
	end
	return false
end

function Scheduler:get_next_timeout()
	return table.remove(self.timer_queue, 1)
end

function Scheduler:set_active_event(event)
	self.active_event = event
end

function Scheduler:get_active_event()
	return self.active_event
end

function Scheduler:new(system_type)
	local o = {}
	setmetatable(o, { __index = self })
	o.state_machine_list = {}
	o.event_queue = {}
	o.timer_queue = {}
	if system_type == self.type.DESKTOP then
		o.time = desktop_time
		o.timeout = DESKTOP_TIMEOUT
	elseif system_type == self.type.CONTROLLER then
		o.time = controller_time
		o.timeout = CONTROLLER_TIMEOUT
	end
	return o
end

function Scheduler:run()
	print("Scheduler running.")
	local success, status, state_machine
	local start = self.time()

	while(true) do	
		local timer, event

		if start+self.timeout < self.time() then -- terminate after timeout
			print(table.getn(self.event_queue))
			break
		end
		
		if self:check_timers() then
			timer = self:get_next_timeout()
			state_machine = self.state_machine_list[timer:event():state_machine_id()]
			self:set_active_event(timer:event())
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self:remove_state_machine(state_machine:id())
				break
			elseif status == StateMachine.TERMINATE_SYSTEM then
				break
			end
		
		elseif self:check_events() then
			event = self:get_next_event()
			state_machine = self.state_machine_list[event:state_machine_id()]
			self:set_active_event(event)
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self:remove_state_machine(state_machine:id())
				break
			elseif status == StateMachine.TERMINATE_SYSTEM then
				break
			end
			
		end
	end
	print("Terminating system...")
end