local Event = {}

function Event:new(state_machine_id, event_type, user_data)
	local data = {state_machine_id = state_machine_id, event_type = event_type, user_data = user_data}
	local o = {}

	o.state_machine_id = function ()
		return data.state_machine_id
	end

	o.type = function ()
		return data.event_type
	end

	o.get_data = function ()
		return data.user_data
	end

	o.set_data = function (user_data)
		data.user_data = user_data
	end

	o.timer_id = function ()
		return data.timer_id
	end

	o.set_timer_id = function (timer_id)
		data.timer_id = timer_id
	end

	return o
end

return Event