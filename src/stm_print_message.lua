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
		print("Handling event in state machine "..self:id())
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == StateMachine.TERMINATE_SELF then
			break
		elseif current_state == S0 then
			if event:type() == self.events.MESSAGE then
				print(tostring(event:get_data()))
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)
			else
				print("Invalid event for this state.")
				print(event:to_string())
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end
		else
			print("Invalid state.")
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end
	coroutine.yield(StateMachine.TERMINATE_SELF)
end

return PrintMessageSTM