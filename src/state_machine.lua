StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,
}

function StateMachine:fire(event, scheduler)
	error("'fire' function not implemented for this state machine!")
end

function StateMachine:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

return StateMachine