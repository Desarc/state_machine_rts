package.path = "/wo/?.lua;"..package.path

local Scheduler = require "sched"
local Event = require "event"
--local STMBusyWork = require "stm-busy"
local STMExternalConnection = require "stm-conn"
local STMQueueLength = require "stm-queue"
--local STMCounter = require "stm-count"
local STMEventGenerator = require "stm-gen"
local STMSimpleTask = require "stm-task"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

--local stm_tlc001 = TrafficLightController:new("stm_tlc001", scheduler)

--local stm_pl001 = PeriodicTimer:new("stm_pl001", scheduler)

local stm_ec1 = STMExternalConnection:new("stm_ec1", scheduler)

local stm_ql1 = STMQueueLength:new("stm_ql1", scheduler)

local stm_eg1 = STMEventGenerator:new("stm_eg1", scheduler)

local stm_st1 = STMSimpleTask:new("stm_st1", scheduler)

--local stm_c1 = STMCounter:new("stm_c1", scheduler)

--local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)

--local stm_pm1 = PrintMessageSTM:new("stm_pm1", scheduler)

--local event1 = Event:new(stm_bw1:id(), STMBusyWork.events.START)

local event1 = Event:new(stm_ec1.id(), STMExternalConnection.events.CONNECT)

local event2 = Event:new(stm_ql1.id(), STMQueueLength.events.START)

local event3 = Event:new(stm_eg1.id(), STMEventGenerator.events.START)

scheduler.add_event(event1)
scheduler.add_event(event2)
scheduler.add_event(event3)
scheduler:run()
