package.path = "/wo/?.lua;"..package.path

local Scheduler = require "sched"
local Event = require "event"
local STMTcpClient = require "stm-tcp-client"
local STMMemoryLogger = require "stm-mem"
local STMSimpleTask = require "stm-task"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_tc1 = STMTcpClient:new("stm_tc1", scheduler)

local stm_ml1 = STMMemoryLogger:new("stm_ml1", scheduler)

local stm_st1 = STMSimpleTask:new("stm_st1", scheduler)

local event1 = Event:new(stm_tc1.id(), STMTcpClient.events.CONNECT)

local event2 = Event:new(stm_ml1.id(), STMMemoryLogger.events.START)

local event3 = Event:new(stm_tc1.id(), STMSimpleTask.events.START)

scheduler.add_event(event1)
scheduler.add_event(event2)
scheduler.add_event(event3)
scheduler:run()	
