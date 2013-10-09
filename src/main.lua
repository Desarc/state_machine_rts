--LUA_PATH = "src/?;src/?.lua;lib/?;lib/?.lua;lib/?.so;/wo/?;/wo/?.lua"

--require "scheduler"
--require "event"
--require "stm_traffic_light"
--require "stm_periodic_timer"

Scheduler = dofile("/wo/scheduler.lua")
Event = dofile("/wo/event.lua")
TrafficLightController = dofile("/wo/stm_periodic_timer.lua")
PeriodicTimer = dofile("/wo/stm_traffic_light.lua")
PrintMessageSTM = dofile("/wo/stm_print_message.lua")



local function main()

	local scheduler = Scheduler:new()

	local stm_tlc001 = TrafficLightController:new("stm_tlc001", scheduler)

	local stm_pl001 = PeriodicTimer:new("stm_pl001", scheduler)

	local stm_pm1 = PrintMessageSTM:new("stm_pm1", scheduler)

	--local event = Event:new(stm_tlc001:id(), 1)

	--print("SYS_TIMER max delay: " .. tmr.getmaxdelay(tmr.SYS_TIMER))
	--print("SYS_TIMER min delay: " .. tmr.getmindelay(tmr.SYS_TIMER))

	--scheduler:add_to_queue(event)
	scheduler:run()
	
	

end

main()