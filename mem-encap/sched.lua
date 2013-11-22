local StateMachine = require "stm"

local Scheduler = {}

Scheduler.type = {
	DESKTOP = 1,
	CONTROLLER = 2,
}

local function controller_time()
	return tmr.read(tmr.SYS_TIMER)
end

local function desktop_time()
	return os.time()
end

local function timers_cmp(t1, t2)
	if t1.expires() < t2.expires() then return true end
end

function Scheduler:new(system_type)
	local o = {}
	setmetatable(o, { __index = self })
	local state_machine_list = {}
	local event_queue = {}
	local timer_queue = {}
	local active_event

	if system_type == self.type.DESKTOP then
		o.time = desktop_time
	elseif system_type == self.type.CONTROLLER then
		o.time = controller_time
	end

	o.add_state_machine = function (state_machine)
		state_machine.run = coroutine.create(state_machine.fire)
		state_machine_list[state_machine.id()] = state_machine
		print("State machine '"..state_machine.id().."' added to scheduler.")
	end

	o.get_state_machine = function (id)
		return state_machine_list[id]
	end

	o.remove_state_machine = function (id)
		if state_machine_list[id] then
			result = true
			print("State machine '"..id.."' removed from scheduler.")
		end
		state_machine_list[id] = nil
		return result
	end

	o.add_event = function (event)
		table.insert(event_queue, event)
	end

	o.check_events = function ()
		if event_queue[1] then return true
		else return false end
	end

	o.get_next_event = function ()
		return table.remove(event_queue, 1)
	end

	o.add_timer = function (timer)
		if timer.expires() then
			table.insert(timer_queue, timer)
			table.sort(timer_queue, timers_cmp)
		end
	end

	o.stop_timer = function (id)
		for k, v in pairs(timers) do
			if v.id() == id then
				table.remove(timers, k)
				break
			end
		end
	end

	o.check_timers = function ()
		local now = o.time()
		if timer_queue[1] then
			if timer_queue[1].expires() < now then return true end
		end
		return false
	end

	o.get_next_timeout = function ()
		return table.remove(timer_queue, 1)
	end

	o.set_active_event = function (event)
		active_event = event
	end

	o.get_active_event = function ()
		return active_event
	end

	return o
end

function Scheduler:run()
	print("Scheduler running.")
	local success, status, state_machine

	while(true) do	
		local timer, event
		
		if self.check_timers() then
			timer = self.get_next_timeout()
			state_machine = self.get_state_machine(timer.event().state_machine_id())
			self.set_active_event(timer.event())
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self.remove_state_machine(state_machine.id())
				break
			elseif status == StateMachine.TERMINATE_SYSTEM then
				break
			end

		elseif self.check_events() then
			event = self.get_next_event()
			state_machine = self.get_state_machine(event.state_machine_id())
			self.set_active_event(event)
			success, status = coroutine.resume(state_machine.run, state_machine)
			if not success then
				print("Success: "..tostring(success)..", status: "..status)
				self.remove_state_machine(state_machine.id())
				break
			elseif status == StateMachine.TERMINATE_SYSTEM then
				break
			end

		end
	end
	print("Terminating system...")
end

return Scheduler