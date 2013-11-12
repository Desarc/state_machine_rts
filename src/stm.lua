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

-- all StateMachine objects must have an ID.
-- the ID should be assigned by the application or preferrably the scheduler upon creation.
function StateMachine:id()
	if self.data then
		return self.data.id
	else
		error("StateMachine has no ID!")
	end
end

-- retrieve the current state of the state machine.
-- a state machine must always be in a state.
function StateMachine:get_state()
	if self.data then
		return self.data.current_state
	else
		error("StateMachine has no state!")
	end
end


-- set the current state of the state machine.
-- a state machine must always be in a state.
function StateMachine:set_state(state)
	if not self.data then
		self.data = {}
	end
	self.data.current_state = state
end


function StateMachine:to_string()
	return tostring(self:id())..": "..tostring(self:get_state())
end

-- StateMachine:new()
-- function for creating a new StateMachine object (constructor).
-- subclass constructors should be in the following format:
--[[

	SomeStateMachine = StateMachine:new()

	function SomeStateMachine:new(id, scheduler)
		o = {}
		setmetatable(o, { __index = self})		-- inherit functions from parent object
		o.data = {}								-- create a table for "private" variables and data
		o.data.id = id 							-- a StateMachine must always have an ID, so this should be part of the constructor
		o.data.current_state = <initial_state> 	-- set initial state
		o.scheduler = scheduler					-- make a reference to the responsible scheduler (e.g. for timer handling)
		scheduler:add_state_machine(o)			-- add this StateMachine instance to scheduler's list
		return o
	end

--]]
function StateMachine:new()
	local o = {}
	setmetatable(o, { __index = self })
	return o
end

return StateMachine