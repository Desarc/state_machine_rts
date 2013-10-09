StateMachine = dofile("/wo/state_machine.lua")
Timer = dofile("/wo/timer.lua")
Event = dofile("/wo/event.lua")

local S0 = "S0"

PrintMessageSTM = StateMachine:new()

PrintMessageSTM.events = {
	MESSAGE = 1,
}

function PrintMessageSTM:new(id, scheduler)
	o = {}
	setmetatable(o, { __index = self})
	o.data = {}
	o.data.id = id
	o.data.current_state = S0
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function PrintMessageSTM:fire()
	while(true) do
		event = self.scheduler:get_active_event()

		if event:type() == self.TERMINATE_SELF then
			break
		elseif self.data.current_state == S0 then
			if event:type() == self.events.MESSAGE then
				print(event:get_data())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			end
		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
end

return PrintMessageSTM