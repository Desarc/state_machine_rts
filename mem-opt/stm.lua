StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,
}

StateMachine.run = nil -- for documentation purposes only

function StateMachine:fire()
	error("'fire' function not yet implemented for this state machine!")
end

function StateMachine.create_event(event, id, type, data)
	if event then
		event.id = id
		event.type = type
		event.data = data
	else
		event = Event:new(id, type, data)
	end
	return event
end

function StateMachine.create_timer(timer, id, expires, event)
	if timer then
		timer.id = id
		timer:renew(expires)
		timer.event = event
	else
		timer = Timer:new(id, expires, event)
	end
	return timer
end

function StateMachine:new()
	local o = {}
	setmetatable(o, { __index = self })
	return o
end