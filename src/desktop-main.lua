Scheduler = require "scheduler"
Event = require "event"
STMEventGenerator = require "stm-desktop-event-gen"
--STMBusyWork = require "stm_busy_work"
STMTcpSocket = require "stm-tcp"
STMLogger = require "stm-logger"
--STMTrafficLight = require "stm_traffic_light"
--STMPeriodicTimer = require "stm_periodic_timer"



local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)

local stm_ts1 = STMTcpSocket:new("stm_ts1", scheduler)

local stm_l1 = STMLogger:new("stm_l1", scheduler)

--local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)


local event1 = Event:new(stm_eg1:id(), STMEventGenerator.events.START)

local event2 = Event:new(stm_l1:id(), STMLogger.events.START, "queue.txt")

local event5 = Event:new(stm_ts1:id(), STMTcpSocket.events.CONNECT)

scheduler:add_to_queue(event2)
scheduler:add_to_queue(event5)
scheduler:add_to_queue(event1)
scheduler:run()	
