local StateMachine = require "stm"

local DESKTOP_TIMEOUT = 10e10
local CONTROLLER_TIMEOUT = 30000000

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
	local active_event, timeout
	local state_machines = {}
	local event_queue = {}
	local timer_queue = {}

	if system_type == self.type.DESKTOP then
		o.time = desktop_time
		timeout = DESKTOP_TIMEOUT
	elseif system_type == self.type.CONTROLLER then
		o.time = controller_time
		timeout = CONTROLLER_TIMEOUT
	end

	o.add_state_machine = function (state_machine)
		-- create a coroutine to resume when calling <state_machine>.run()
		-- the coroutine should call the <state_machine>:fire() function when resumed 
		state_machine.run = coroutine.create(state_machine.fire)
		-- index by ID (must be unique)
		state_machines[state_machine.id()] = state_machine
		print("State machine '"..state_machine.id().."' added to scheduler.")
	end

	o.remove_state_machine = function (state_machine)
		if state_machines[state_machine.id()] then
			result = true -- return true if state machine existed
			print("State machine '"..state_machine.id().."' removed from scheduler.")
		end
		state_machines[state_machine.id()] = nil
		return result
	end

	o.add_event = function (event)
		table.insert(event_queue, event)
	end

	o.get_next_event = function ()
		return table.remove(event_queue, 1)
	end

	o.event_queue_length = function ()
		return table.getn(event_queue)
	end

	o.timer_queue_length = function ()
		return table.getn(timer_queue)
	end

	o.set_active_event = function (event)
		active_event = event
	end

	o.get_active_event = function ()
		local event = active_event
		active_event = nil
		return event
	end

	o.add_timer = function (timer)
		if timer.expires() then
			table.insert(timer_queue, timer)
			table.sort(timer_queue, timers_cmp)
		end
	end

	o.stop_timer = function (id)
		for k, v in pairs(timer_queue) do
			if v.id() == id then
				table.remove(timer_queue, k)
				break
			end
		end
	end

	o.check_timers = function ()
		local now = o.time()
		if timer_queue[1] then
			if timer_queue[1].expires() < now then return table.remove(timer_queue, 1) end
		end
	end

	o.run = function (self)
		print("Scheduler running.")
		-- TODO: passive waiting if no events/timers?
		-- power consumption
		local success, status, state_machine
		local start = self.time()

		while(true) do
			
			--if start+timeout < self.time() then -- terminate after timeout
			--	print("Ran for 30 sec, terminating...")
			--	break
			--end
			
			local timer = self.check_timers()
			if timer then
				--print("Timer expired!")
				state_machine = state_machines[timer.event().state_machine_id()]
				self.set_active_event(timer.event())
				success, status = coroutine.resume(state_machine.run, state_machine)
				if not success then
					print("Success: "..tostring(success)..", status: "..status)
					self.remove_state_machine(state_machine)
					break
				elseif status == StateMachine.TERMINATE_SYSTEM then
					break
				end
			end

			local event = self.get_next_event()
			if event then
				--print("Event received!")
				state_machine = state_machines[event.state_machine_id()]
				self.set_active_event(event)
				success, status = coroutine.resume(state_machine.run, state_machine)
				if not success then
					print("Success: "..tostring(success)..", status: "..status)
					self.remove_state_machine(state_machine)
					break
				elseif status == StateMachine.TERMINATE_SYSTEM then
					break
				end
			end
		end
		print("Terminating system...")
	end

	return o
end

return Scheduler