local Message = {}

function Message.deserialize(content)
	local message = Message:new({})
	local done = false
	local delim1, delim2, key, value = 0, 0
	while(not done) do
		delim1 = string.find(content, ":", delim2+1)
		if delim1 == nil then
			break
		end
		key = string.sub(content, delim2+1, delim1-1)
		delim2 = string.find(content, ";", delim1+1)
		if delim2 == nil then
			break
		end
		value = string.sub(content, delim1+1, delim2-1)
		message.add_data(key, value)
	end
	return message
end

function Message:new(variables)
	local o = {}
	setmetatable(o, { __index = self })
	local data = variables

	o.serialize = function ()
		local serialized = ""
		for i,v in pairs(data) do
			if v ~= nil then
				serialized = serialized..tostring(i)..":"..tostring(v)..";"
			end
		end
		return serialized.."\n"
	end

	o.generate_event = function ()
		local state_machine_id, event_type, user_data
		if data.stm_id then
			state_machine_id = data.stm_id
		else
			return nil
		end
		if data.event_type then
			event_type = tonumber(data.event_type)
		else
			return nil
		end
		user_data = data.user_data	
		return Event:new(state_machine_id, event_type, user_data)
	end

	o.add_data = function (key, value)
		data[key] = value
	end

	return o
end

return Message