-- list of state machines
local state_machine_list = {}

local function add_state_machine(state_machine)
	state_machine_list[state_machine:id()] = coroutine.create(state_machine.fire)
end

local function remove_state_machine(state_machine)
	state_machine_list[state_machine:id()] = nil
end

-- event queue
local event_queue = {}

local function add_to_queue(event)
	table.insert(event_queue, event)
end

local function get_next_event()
	return table.remove(event_queue, 1)
end

local timers = {}

local function timers_cmp(t1, t2)
	if t1:expires() < t2:expires() then return true end
end

-- add timer to list based on expiry time
local function add_timer(timer)
	if timer:expires() then
		table.insert(timers, timer)
		table.sort(timers, timers_cmp)
	end
end

local function stop_timer(id)
	for k, v in timers do
		if v:id() == id then
			table.remove(timers, k)
			break
		end
	end
end

local function check_timers()
	local now = os.time()
	if timers[1] then
		if timers[1]:expires() < now then return table.remove(timers, 1) end
	end
end

Scheduler = {
	add_state_machine = add_state_machine,
	remove_state_machine = remove_state_machine,
	add_to_queue = add_to_queue,
	add_timer = add_timer,
}

function Scheduler:run()
	while(true) do
		timer = check_timers()
		if timer then
			coroutine.resume(state_machine_list[timer:state_machine()], timer:event(), self)
			--state_machine_list[timer:state_machine()]:fire(timer:event(), self)
		end
		event = get_next_event()
		if event then
			print("Processing event...")
			coroutine.resume(state_machine_list[event:state_machine()], event, self)
			--state_machine_list[event:state_machine()]:fire(event, self)
		end
	end
end

return Scheduler