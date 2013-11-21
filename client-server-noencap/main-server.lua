require "sched"
require "event"
require "msg"
require "timer"
require "stm"
require "stm-print"
require "stm-tcp-server"
require "stm-req"
require "stm-tcp-client"
require "stm-gen"

local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

local stm_ts1 = STMTcpServer:new("stm_ts1", scheduler)

local stm_rh1 = STMRequestHandler:new("stm_rh1", scheduler)

local event1 = Event:new(stm_ts1:id(), STMTcpServer.events.CONNECT)

scheduler:add_event(event1)
scheduler:run()	
