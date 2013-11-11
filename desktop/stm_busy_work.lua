require "state_machine"
require "timer"
require "event"
require "logger"

local ACTIVE, IDLE = "Active", "Idle"
local EVENT_INTERVAL = 1

logger = Logger:new("busy_work_stm.txt")

local function busy_work()
	for i=1,10000000 do
		q = i*i
	end
	logger:log(tostring(os.clock()))
end

STMBusyWork = StateMachine:new()

STMBusyWork.events = {
	START = 1,
	STOP = 2,
	DO_WORK = 3,
	EXIT = 4,
}

function STMBusyWork:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {}
	o.data.id = id
	o.data.current_state = IDLE
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	o.count = 0
	return o
end

function STMBusyWork:schedule_self()
	local event = Event:new(self.data.id, self.events.DO_WORK)
	self.scheduler:add_to_queue(event)
end

function STMBusyWork:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:get_state()

		if event:type() == self.TERMINATE_SELF then
			break

		elseif current_state == IDLE then
			if event:type() == self.events.START then
				print(os.clock())
				self:schedule_self()
				self:set_state(ACTIVE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				coroutine.yield(StateMachine.TERMINATE_SYSTEM)
			end
		
		elseif current_state == ACTIVE then
			if event:type() == self.events.DO_WORK then
				busy_work()
				if self.count < 500 then
					self:schedule_self()
					self.count = self.count + 1
					coroutine.yield(StateMachine.EXECUTE_TRANSITION)
				else
					print(os.clock())
					coroutine.yield(StateMachine.TERMINATE_SYSTEM)
				end

			elseif event:type() == self.events.STOP then
				self:set_state(IDLE)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			elseif event:type() == self.events.EXIT then
				
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMBusyWork