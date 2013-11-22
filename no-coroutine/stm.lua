StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,
}

function StateMachine:fire()
	error("'fire' function not yet implemented for this state machine!")
end

function StateMachine:create_event(event, id, type, data)
	if event then
		event:set_id(id)
		event:set_type(type)
		event:set_data(data)
	else
		event = Event:new(id, type, data)
	end
	return event
end

function StateMachine:set_timer(timer, id, expires, event)
	if timer then
		timer:set_id(id)
		timer:renew(expires)
		timer:set_event(event)
	else
		timer = Timer:new(id, expires, event)
	end
	self.scheduler:add_timer(timer)
	return timer
end

function StateMachine:new()
	local o = {}
	setmetatable(o, { __index = self })
	return o
end