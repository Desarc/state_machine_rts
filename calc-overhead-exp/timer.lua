Timer = {
	BASE = 1000, -- number of time units for 1ms
}

function Timer:renew(expires)
	self.expires = self.time()+expires
end

function Timer.time()
	return tmr.read(tmr.SYS_TIMER)
end

function Timer:new(id, expires, event)
	local o = {}
	setmetatable(o, { __index = self })
	o.id = id
	o.expires = self.time()+expires
	o.event = event
	return o
end