StateMachine = require "stm"

local COUNTING = "counting"

STMCounter = StateMachine:new()

STMCounter.events = {
	COUNT = 1,
	RESET = 2,
	PRINT = 3,
}

function STMCounter:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(COUNTING)
	o.scheduler = function ()
		return sched
	end
	o.count = 0
	scheduler:add_state_machine(o)
	return o
end

function STMCounter:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.get_state()

		if current_state == COUNTING then
			if event.type() == self.events.COUNT then
				self.count = self.count + 1
				print("+1! Total count is now "..tostring(self.count))
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.RESET then
				self.count = 0
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.PRINT then
				print("Total count is now "..tostring(self.count))
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMCounter