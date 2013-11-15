Event = require "event"

Message = {}

function Message:serialize()
	local serialized_str = ""
	for i,v in pairs(self.data) do
		if v ~= nil then
			serialized_str = serialized_str..tostring(i)..":"..tostring(v)..";"
		end
	end
	return serialized_str..'\n'
end

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
		message.data[key] = value
	end
	return message
end

function Message:generate_event()
	local state_machine_id, event_type, user_data
	if self.data.stm_id then
		state_machine_id = self.data.stm_id
	else
		return nil
	end
	if self.data.event_type then
		event_type = tonumber(self.data.event_type)
	else
		return nil
	end
	user_data = self.data.user_data	
	return Event:new(state_machine_id, event_type, user_data)
end

function Message:content_index()
	local content_str = ""
	for k, v in pairs(self.data) do
		content_str = content_str.." "..k
	end
	return content_str
end

function Message:lookup(key)
	return self.data[key]
end

--[[
	call this constructor with a table constructor as argument, e.g.

	local message = Message:new{title="welcome", address="home", content="hello"}

	message may contain any variables
]]
function Message:new(variables)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	for k,v in pairs(variables) do
		o.data[k] = v
	end
	return o
end

return Message