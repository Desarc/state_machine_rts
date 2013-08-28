LUA_PATH = "src/?;src/?.lua;lib/?;lib/?.lua;lib/?.so"

require "scheduler"
require "event"
require "zmq"
require "llthreads"
require "stm_traffic_light"
require "stm_periodic_timer"

local function main()

	local scheduler = Scheduler:new()

	local stm_tlc001 = TrafficLightController:new("stm_tlc001", scheduler)

	local stm_pl001 = PeriodicTimer:new("stm_pl001", scheduler)

	local event = Event:new(stm_tlc001:id(), 1)

	scheduler:add_to_queue(event)
	scheduler:run()
	
	

end

main()