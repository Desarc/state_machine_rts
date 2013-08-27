Timer = {}

function Timer:expires()
	return self.data.expires
end

function Timer:state_machine()
	return self.data.state_machine
end

function Timer:event()
	return self.data.event
end

function Timer:id()
	return self.data.id
end

function Timer:new(expires, state_machine, event)
	o = {}
	setmetatable(o, { __index = self })
	local id = state_machine .. tostring(os.clock())
	o.data = {id = id, expires = expires, state_machine = state_machine, event = event}
	return o
end

return Timer