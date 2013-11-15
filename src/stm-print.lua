local StateMachine = require "state_machine"
local Timer = require "timer"
local Event = require "event"

local ACTIVE = "active"

local PrintMessageSTM = StateMachine:new()

PrintMessageSTM.events = {
	PRINT = 1,
}

function PrintMessageSTM:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(ACTIVE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function PrintMessageSTM:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == ACTIVE then
			if event.type() == self.events.PRINT then
				print(tostring(event.user_data()))
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