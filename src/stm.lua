-- the base StateMachine table (object).
-- the defined constants are general status messages valid for any state machine.
StateMachine = {
	EXECUTE_TRANSITION = 0,
	DISCARD_EVENT = 1,
	TERMINATE_SYSTEM = 2,
}

-- StateMachine.run()
-- this function should be replaced by a coroutine created by the scheduler.
function StateMachine.run()
	error("No coroutine created for this state machine!")
end

-- StateMachine:fire()
-- this is the function called by the coroutine, and should implement all transitions specified for the state machine.
-- the transitions should be enclosed in a while(true) block to keep the coroutine alive.
-- use an if-else control structure to make sure processing starts at the beginning of the while block when the coroutine is resumed.
-- every transition must end with coroutine.yield(<status_message>) to give control back to the scheduler.
-- the while block should begin by retrieving the event that is due to be processed. 
function StateMachine:fire()
	error("'fire' function not yet implemented for this state machine!")
end

-- StateMachine:new()
-- function for creating a new StateMachine object (constructor).
-- subclass constructors should be in the following format:
--[[

	SomeStateMachine = StateMachine:new()

	function SomeStateMachine:new(id, scheduler)
		local o = {}
		setmetatable(o, { __index = self })
		local sched = scheduler
		o.set_id(id)
		o.set_id = function () error("Function not accessible.") end -- make parent function inaccessible
		o.set_state(IDLE)
		o.scheduler = function ()
			return sched
		end
		scheduler:add_state_machine(o)
		return o
	end

--]]
function StateMachine:new()
	local o = {}
	setmetatable(o, { __index = self })
	local data = {state = nil, id = nil} -- will be set upon instantiation of subclass
	o.state = function ()
		return data.state
	end
	o.set_state = function (state)
		data.state = state
	end
	o.set_id = function (id)
		data.id = id
	end
	o.id = function ()
		return data.id
	end
	o.to_string = function()
		return tostring(data.id)..": "..tostring(data.state)
	end
	return o
end

return StateMachine