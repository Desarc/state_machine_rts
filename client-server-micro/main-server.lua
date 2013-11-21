local Scheduler = require "sched"
local Event = require "event"
local STMTcpServer = require "stm-tcp-server"
local STMRequesthandler = require "stm-req"

local scheduler = Scheduler:new(Scheduler.type.DESKTOP)

local stm_ts1 = STMTcpServer:new("stm_ts1", scheduler)

local stm_rh1 = STMRequesthandler:new("stm_rh1", scheduler)

local event1 = Event:new(stm_ts1.id(), STMTcpServer.events.CONNECT)

scheduler.add_event(event1)
scheduler:run()	
