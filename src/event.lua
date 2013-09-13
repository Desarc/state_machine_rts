Event = {}

function Event:state_machine_id()
	return self.data.state_machine_id
end

function Event:type()
	return self.data.type
end

function Event:new(state_machine_id, type)
	o = {}
	setmetatable(o, { __index = self })
	o.data = {state_machine_id = state_machine_id, type = type}
	return o
end

return Event