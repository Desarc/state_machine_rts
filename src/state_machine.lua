StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,

	TERMINATE_SELF = -1,
}

function StateMachine:fire()
	error("'fire' function not implemented for this state machine!")
end

function StateMachine.run()
	error("No coroutine created for this state machine!")
end

function StateMachine:id()
	if self.data then
		return self.data.id
	end
end

function StateMachine:new()
	o = {}
	setmetatable(o, { __index = self })
	return o
end

return StateMachine