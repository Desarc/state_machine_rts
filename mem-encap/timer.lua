local Timer = {
	BASE = 1000,
}

local function time()
	return tmr.read(tmr.SYS_TIMER)
end

function Timer:new(id, expires, event)
	local data = {id = id, expires = time()+expires, event = event}
	local o = {}

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