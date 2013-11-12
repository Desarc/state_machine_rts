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

function Timer.time()
	return tmr.read(tmr.SYS_TIMER)
end

function Timer:new(id, expires, state_machine_id, event)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, expires = self.time()+expires, state_machine_id = state_machine_id, event = event}
	return o
end

return Timer