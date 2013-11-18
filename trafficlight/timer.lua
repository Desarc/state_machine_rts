local Timer = {}

local function time()
	return os.time()
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