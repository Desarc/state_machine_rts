Event = {}

function Event:new(state_machine_id, event_type, user_data)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {state_machine_id = state_machine_id, event_type = event_type, user_data = user_data}
	
	o.type = function ()
		return data.event_type
	end

	o.user_data = function ()
		return data.user_data
	end

	o.state_machine_id = function ()
		return data.state_machine_id
	end

	o.timer_id = function ()
		return data.timer_id
	end

	o.set_timer_id = function (timer_id)
		data.timer_id = timer_id
	end

	o.to_string = function ()
		return tostring(data.state_machine_id).."\n"..tostring(data.event_type).."\n"..tostring(data.user_data).."\n"
	end

	return o
end

return Event