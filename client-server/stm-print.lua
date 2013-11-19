local StateMachine = require "state_machine"
local Event = require "event"

local ACTIVE = "active"

local PrintMessageSTM = StateMachine:new()

PrintMessageSTM.events = {
	PRINT = 1,
}

function PrintMessageSTM:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local data = {id = id, state = ACTIVE}
	local sched = scheduler

	o.id = function ()
		return data.id
	end

	o.state = function ()
		return data.state
	end

	o.set_state = function (state)
		data.state = state
	end

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
				print(tostring(event.get_data()))
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