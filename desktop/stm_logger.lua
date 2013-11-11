require "state_machine"
require "logger"

local INACTIVE, ACTIVE = "active", "inactive"

STMLogger = StateMachine:new()

STMLogger.events = {
	START = 1,
	LOG = 2,
	EXIT = 4,
}

function STMLogger:log(data)
	print("Logging data...")
	self.logger:log(data)
end

function STMLogger:open(filename)
	self.logger = Logger:new(filename)
end

function STMLogger:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = INACTIVE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMLogger:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			self.logger:close()
			break

		elseif current_state == INACTIVE then
			if event:type() == self.events.START then
				self:open(event:get_data())
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event:type() == self.events.LOG then
				self:log(event:get_data())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				self.logger:close()
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMLogger