LUA_PATH = "src/?;src/?.lua;lib/?;lib/?.lua;lib/?.so"

require "scheduler"
require "event"
require "luaproc"
require "stm_traffic_light"
require "stm_periodic_timer"

local function main()

	local scheduler = Scheduler:new()

	stm_tlc001 = TrafficLightController:new("stm_tlc001", scheduler)

	stm_pl001 = PeriodicTimer:new("stm_pl001", scheduler)

	event = Event:new(stm_tlc001:id(), 1)

	luaproc.createworker()

	--luaproc.newproc ( [==[
	--		scheduler:run()
	--	]==])

	scheduler:add_to_queue(event)
	scheduler:run()
	
	

end

main()