local StateMachine = require "stm"
local Logger = require "logger"

local INACTIVE, ACTIVE = "active", "inactive"

local STMLogger = StateMachine:new()

STMLogger.events = {
	START = 1,
	LOG = 2,
	STOP = 3,
}

function STMLogger:log(data)
	print("Logging data...")
	self.logger.log(data)
end

function STMLogger:open(filename)
	self.logger = Logger:new(filename)
end

function STMLogger:close()
	self.logger.close()
end

function STMLogger:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	local sched = scheduler
	o.set_id(id)
	o.set_id = function () error("Function not accessible.") end
	o.set_state(INACTIVE)
	o.scheduler = function ()
		return sched
	end
	scheduler.add_state_machine(o)
	return o
end

function STMLogger:fire()
	while(true) do
		local event = self.scheduler().get_active_event()
		local current_state = self.state()

		if current_state == INACTIVE then
			if event.type() == self.events.START then
				self:open(event.user_data())
				self.set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ACTIVE then
			if event.type() == self.events.LOG then
				self:log(event.user_data())
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event.type() == self.events.STOP then
				self:close()
				self.set_state(INACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMLogger