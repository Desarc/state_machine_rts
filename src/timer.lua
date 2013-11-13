Timer = {
	BASE = 1000, -- number of time units for 1ms
}

function Timer.time()
	return tmr.read(tmr.SYS_TIMER)
end

function Timer:new(id, expires, event)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, expires = self.time()+expires, event = event}
	o.id = function ()
		return data.id
	end
	o.expires = function ()
		return data.expires
	end
	o.event = function ()
		return data.event
	end
	return o
end

return Timer