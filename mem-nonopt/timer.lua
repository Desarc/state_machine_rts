Timer = {
	BASE = 1000, -- number of time units for 1ms
}

function Timer:expires()
	return self.data.expires
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

function Timer:new(id, expires, event)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, expires = self.time()+expires, event = event}
	return o
end