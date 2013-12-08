require "timer"
require "sched"
require "event"
require "stm"
require "msg"
require "logger"
require "stm-tcp-server"
require "stm-logger"

Scheduler:set_up(Scheduler.type.DESKTOP)

local stm_ts1 = STMTcpServer:new("stm_ts1", Scheduler)

local stm_l1 = STMLogger:new("stm_l1", Scheduler)

local event1 = Event:new(stm_l1.id, STMLogger.events.START, "../matlab/test.txt")

local event2 = Event:new(stm_ts1.id, STMTcpServer.events.CONNECT)

Scheduler:add_event(event1)
Scheduler:add_event(event2)
Scheduler:run()	
