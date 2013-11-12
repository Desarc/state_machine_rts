StateMachine = require "state_machine"
Timer = require "timer"
Event = require "event"

local ACTIVE = "active"

PrintMessageSTM = StateMachine:new()

PrintMessageSTM.events = {
	PRINT = 1,
}

function PrintMessageSTM:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self})
	o.data = {}
	o.data.id = id
	o.data.current_state = ACTIVE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function PrintMessageSTM:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == StateMachine.TERMINATE_SELF then
			break

		elseif current_state == ACTIVE then
			if event:type() == self.events.PRINT then
				print(tostring(event:get_data()))
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			
			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return PrintMessageSTM