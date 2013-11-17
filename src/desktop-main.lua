local Scheduler = require "sched"
local Event = require "event"
--local STMEventGenerator = require "stm-desktop-event-gen"
--local STMBusyWork = require "stm-busy"
local STMTcpSocket = require "stm-tcp"
local STMLogger = require "stm-logger"
--local STMTrafficLight = require "stm-light"
--local STMPeriodicTimer = require "stm-timer"



local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

--local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)

local stm_ts1 = STMTcpSocket:new("stm_ts1", scheduler)

local stm_l1 = STMLogger:new("stm_l1", scheduler)

--local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)

--local stm_tl1 = STMTrafficLight:new("stm_tl1", scheduler)

--local stm_pt1 = STMPeriodicTimer:new("stm_pt1", scheduler)

--local event1 = Event:new(stm_eg1:id(), STMEventGenerator.events.START)

--local event1 = Event:new(stm_tl1:id(), STMTrafficLight.events.PEDESTRIAN_BUTTON_PRESSED)

--local event1 = Event:new(stm_pt1:id(), STMPeriodicTimer.events.START)

local event2 = Event:new(stm_l1:id(), STMLogger.events.START, "../matlab/time50000_1.txt")

local event5 = Event:new(stm_ts1:id(), STMTcpSocket.events.CONNECT)

--local event5 = Event:new(stm_bw1:id(), STMBusyWork.events.START)

scheduler:add_event(event2)
scheduler:add_event(event5)
--scheduler:add_event(event1)
scheduler:run()	
