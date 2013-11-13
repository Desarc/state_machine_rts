Event = require "event"

Message = {}

function Message.deserialize(content)
	local message = Message:new{}
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

--[[
	call this constructor with a table constructor as argument, e.g.

	local message = Message:new{title="welcome", address="home", content="hello"}

	message may contain any variables
]]
function Message:new(variables)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {}
	for k,v in pairs(variables) do
		data[k] = v
	end

	o.lookup = function (key)
		return data[key]
	end

	o.add_data(key, value)
		data[key] = value
	end

	o.serialize = function ()
		local serialized_str = ""
		for i,v in pairs(data) do
			if v ~= nil then
				serialized_str = serialized_str..tostring(i)..":"..tostring(v)..";"
			end
		end
		return serialized_str..'\n'
	end

	o.generate_event = function ()
		local state_machine_id, event_type
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
		return Event:new(state_machine_id, event_type, data.user_data)
	end

	o.content_index = function ()
		local content_str = ""
		for k, v in pairs(data) do
			content_str = content_str.." "..k
		end
		return content_str
	end

	return o
end

return Message