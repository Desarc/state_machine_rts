LUA_PATH = "src/?;src/?.lua"

require "scheduler"
require "event"
require "stm_traffic_light"
require "stm_periodic_timer"

local function main()

	stm_tlc001 = TrafficLightController:new("stm_tlc001")

	stm_pl001 = PeriodicTimer:new("stm_pl001")

	Scheduler.add_state_machine(stm_tlc001)
	Scheduler.add_state_machine(stm_pl001)

	event = Event:new(stm_pl001:id(), 1)

	Scheduler.add_to_queue(event)
	Scheduler:run()

end

main()