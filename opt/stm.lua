StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,
}

StateMachine.run = nil

function StateMachine:fire()
	error("'fire' function not yet implemented for this state machine!")
end

function StateMachine:id()
	if self.data then
		return self.data.id
	else
		error("StateMachine has no ID!")
	end
end

function StateMachine:state()
	if self.data then
		return self.data.state
	else
		error("StateMachine has no state!")
	end
end

function StateMachine:set_state(state)
	if not self.data then
		self.data = {}
	end
	self.data.state = state
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

sfunction StateMachine:new()
	local o = {}
	setmetatable(o, { __index = self })
	return o
end

return StateMachine