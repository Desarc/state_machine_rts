package.path = "/wo/?.lua;"..package.path

require "sched"
require "event"
require "stm-conn"
require "stm-queue"
require "stm-count"

local function main()

	local scheduler = Scheduler:new()

	--local stm_tlc001 = TrafficLightController:new("stm_tlc001", scheduler)

	--local stm_pl001 = PeriodicTimer:new("stm_pl001", scheduler)

	local stm_ec1 = STMExternalConnection:new("stm_ec1", scheduler)
	local stm_ql1 = STMQueueLength:new("stm_ql1", scheduler)
	local stm_c1 = STMCounter:new("stm_c1", scheduler)

	--local stm_pm1 = PrintMessageSTM:new("stm_pm1", scheduler)

	local event1 = Event:new(stm_ec1:id(), STMExternalConnection.events.CONNECT)
	local event2 = Event:new(stm_ql1:id(), STMQueueLength.events.START)

	--print("SYS_TIMER max delay: " .. tmr.getmaxdelay(tmr.SYS_TIMER))
	--print("SYS_TIMER min delay: " .. tmr.getmindelay(tmr.SYS_TIMER))

	scheduler:add_to_queue(event1)
	scheduler:add_to_queue(event2)
	scheduler:run()
	
	

end

main()