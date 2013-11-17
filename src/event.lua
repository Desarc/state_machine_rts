Event = {}

function Event:state_machine_id()
	return self.data.state_machine_id
end

function Event:set_id(id)
	self.data.state_machine_id = id
end

function Event:type()
	return self.data.event_type
end

function Event:set_type(type)
	self.data.event_type = type
end

function Event:get_data()
	return self.data.user_data
end

function Event:set_data(data)
	self.data.user_data = data
end

function Event:to_string()
	return tostring(self:state_machine_id()).."\n"..tostring(self:type()).."\n"..tostring(self:get_data()).."\n"
end

function Event:set_timer(timer)
	self.data.timer = timer
end

function Event:timer()
	return self.data.timer
end

function Event:new(state_machine_id, event_type, user_data)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {state_machine_id = state_machine_id, event_type = event_type, user_data = user_data}
	return o
end

return Event