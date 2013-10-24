Timer = {}

function Timer:expires()
	return self.data.expires
end

function Timer:state_machine_id()
	return self.data.state_machine_id
end

function Timer:event()
	return self.data.event
end

function Timer:id()
	return self.data.id
end

function Timer.now()
	return tmr.read(tmr.SYS_TIMER)
end

function Timer:new(expires, state_machine_id, event)
	o = {}
	setmetatable(o, { __index = self })
	local id = state_machine_id .. expires
	o.data = {id = id, expires = self.now()+expires, state_machine_id = state_machine_id, event = event}
	return o
end

return Timer