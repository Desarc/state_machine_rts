STMLED = StateMachine:new()

local INACTVIE, ON, OFF  = "inactive", "on", "off"

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end

STMLED.events = {
	INIT = 1,
	SET_ON = 2,
	SET_OFF = 3,
}

function STMLED:initiate()
	pio.port.setdir(pio.OUTPUT, pio.PF2_LED1)
end

function STMLED:turn_off()
	print("Setting LED off...")
	pio.port.sethigh(pio.PF2_LED1)
end

function STMLED:turn_on()
	print("Setting LED on..")
	pio.port.setlow(pio.PF2_LED1)
end

function STMLED:new(id, scheduler)
	local o = {}
	setmetatable(o, { __index = self })
	o.data = {id = id, state = INACTIVE}
	o.scheduler = scheduler
	scheduler:add_state_machine(o)
	return o
end

function STMLED:fire()
	while(true) do
		local event = self.scheduler:get_active_event()
		local current_state = self:state()

		if current_state == INACTIVE then
			if event:type() == self.events.INIT then
				self:initiate()
				self:set_state(OFF)
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == OFF then
			if event:type() == self.events.SET_ON then
				self:turn_on()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		elseif current_state == ON then
			if event:type() == self.events.SET_OFF then
				self:turn_off()
				coroutine.yield(StateMachine.EXECUTE_TRANSITION)

			else
				coroutine.yield(StateMachine.DISCARD_EVENT)
			end

		else
			coroutine.yield(StateMachine.DISCARD_EVENT)
		end
	end

end

return STMLED