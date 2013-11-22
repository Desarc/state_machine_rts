require "timer"
require "sched"
require "event"
require "stm"
require "msg"
require "logger"
require "stm-tcp-server"
require "stm-logger"

local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

local stm_ts1 = STMTcpServer:new("stm_ts1", scheduler)

local stm_l1 = STMLogger:new("stm_l1", scheduler)

local event1 = Event:new(stm_l1.id, STMLogger.events.START, "../matlab/mem_nostm_opt.txt")

local event2 = Event:new(stm_ts1.id, STMTcpServer.events.CONNECT)

scheduler:add_event(event1)
scheduler:add_event(event2)
scheduler:run()	
