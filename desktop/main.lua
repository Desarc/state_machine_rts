require "scheduler"
require "event"
--require "stm_event_generator"
require "stm_busy_work"
--require "stm_queue_length"
--require "stm_tcp_socket"
--require "stm_traffic_light"
--require "stm_periodic_timer"



local scheduler = Scheduler:new()

--local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)

--local stm_ts1 = STMTcpSocket:new("stm_ts1", scheduler)

local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)


--local event1 = Event:new(stm_eg1:id(), STMEventGenerator.events.START)

local event1 = Event:new(stm_bw1:id(), STMBusyWork.events.START)

--local event5 = Event:new(stm_ts1:id(), STMTcpSocket.events.CONNECT)


--scheduler:add_to_queue(event5)
scheduler:add_to_queue(event1)
scheduler:run()	
