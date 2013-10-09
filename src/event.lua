Event = {}

function Event:state_machine_id()
	return self.data.state_machine_id
end

function Event:type()
	return self.data.type
end

function Event:get_data()
	return self.data.user_data
end

function Event:new(state_machine_id, type, user_data)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {state_machine_id = state_machine_id, type = type, user_data = user_data}
	return o
end

return Event