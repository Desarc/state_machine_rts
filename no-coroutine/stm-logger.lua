local CLOSED, ACTIVE = 1, 2

STMLogger = StateMachine:new()

STMLogger.events = {
	START = 1,
	LOG = 2,
	STOP = 3,
}

function STMLogger:log(data)
	print("Logging data...")
	self.logger:log(data)
end

function STMLogger:open(filename)
	self.logger = Logger:new(filename)
end

function STMLogger:close()
	self.logger:close()
end

function STMLogger:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.id = id
	o.state = CLOSED
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMLogger:fire(event)
	while(true) do

		if self.state == CLOSED then
			if event.type == self.events.START then
				self:open(event.data)
				self.state = ACTIVE
				return true, StateMachine.EXECUTE_TRANSITION

			else
				return true, StateMachine.DISCARD_EVENT
			end

		elseif self.state == ACTIVE then
			if event.type == self.events.LOG then
				self:log(event.data)
				return true, StateMachine.EXECUTE_TRANSITION

			elseif event.type == self.events.STOP then
				self:close()
				self.state = CLOSED
				return true, StateMachine.EXECUTE_TRANSITION

			else
				return true, StateMachine.DISCARD_EVENT
			end

		else
			return true, StateMachine.DISCARD_EVENT
		end
	end

end