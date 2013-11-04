require "scheduler"
require "event"
require "stm_event_generator"
require "stm_queue_length"
require "socket"
--require "stm_traffic_light"
--require "stm_periodic_timer"


local function main()

	local scheduler = Scheduler:new()

	local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)
	local stm_eg2 = STMEventGenerator:new("stm_eg2", scheduler)
	local stm_eg3 = STMEventGenerator:new("stm_eg3", scheduler)
	local stm_eg4 = STMEventGenerator:new("stm_eg4", scheduler)

	local stm_ql1 = STMQueueLength:new("stm_ql1", scheduler)

	--local stm_ec1 = ExternalConnectionSTM:new("stm_ec1", scheduler)

	--local stm_pm1 = PrintMessageSTM:new("stm_pm1", scheduler)

	local event1 = Event:new(stm_eg1:id(), STMEventGenerator.events.START)
	local event2 = Event:new(stm_eg2:id(), STMEventGenerator.events.START)
	local event3 = Event:new(stm_eg3:id(), STMEventGenerator.events.START)
	local event4 = Event:new(stm_eg4:id(), STMEventGenerator.events.START)
	local event5 = Event:new(stm_ql1:id(), STMQueueLength.events.START)

	scheduler:add_to_queue(event1)
	scheduler:add_to_queue(event2)
	scheduler:add_to_queue(event3)
	scheduler:add_to_queue(event4)
	scheduler:add_to_queue(event5)
	scheduler:run()	

end

main()