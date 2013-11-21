local ACTIVE = 1

STMPrintMessage = StateMachine:new()

STMPrintMessage.events = {
	PRINT = 1,
}

function STMPrintMessage:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = ACTIVE}
	self.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMPrintMessage:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == ACTIVE then
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

return STMPrintMessage