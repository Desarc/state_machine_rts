Event = {}

function Event:state_machine_id()
	return self.data.state_machine_id
end

function Event:type()
	return self.data.event_type
end

function Event:get_data()
	return self.data.user_data
end

function Event:set_timer_id(timer_id)
	self.data.timer_id = timer_id
end

function Event:timer_id()
	return self.data.timer_id
end

function Event:new(state_machine_id, event_type, user_data)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {state_machine_id = state_machine_id, event_type = event_type, user_data = user_data}
	return o
end