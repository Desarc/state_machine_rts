Event = {}

function Event:new(id, type, data)
	local o = {}
	o.state_machine_id = state_machine_id
	o.type = type
	o.data = data
	return o
end
