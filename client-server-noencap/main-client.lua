package.path = "/wo/?.lua;"..package.path

require "sched"
require "event"
require "msg"
require "timer"
require "stm"
require "stm-print"
require "stm-tcp-client"
require "stm-gen"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_tc1 = STMTcpClient:new("stm_tc1", scheduler)

local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)

local stm_pm1 = STMPrintMessage:new("stm_pm1", scheduler)

local event1 = Event:new(stm_tc1:id(), STMTcpClient.events.CONNECT)

local event2 = Event:new(stm_eg1:id(), STMEventGenerator.events.START)

scheduler:add_event(event1)
scheduler:add_event(event2)
scheduler:run()	
