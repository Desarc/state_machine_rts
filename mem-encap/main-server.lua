local Scheduler = require "sched"
local Event = require "event"
local STMTcpServer = require "stm-tcp-server"
local STMLogger = require "stm-logger"

local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

local stm_ts1 = STMTcpServer:new("stm_ts1", scheduler)

local stm_l1 = STMLogger:new("stm_l1", scheduler)

local event1 = Event:new(stm_ts1.id(), STMTcpServer.events.CONNECT)

local event2 = Event:new(stm_l1.id(), STMLogger.events.START, "../matlab/mem_stm_encap.txt")

scheduler.add_event(event1)
scheduler.add_event(event2)
scheduler:run()	
