package.path = "/wo/?.lua;"..package.path

print("step: "..collectgarbage("setstepmul", 200))
--print("pause: "..collectgarbage("setpause", 110))

require "stm"
require "sched"
require "event"
require "timer"
require "msg"
require "stm-conn"
require "stm-mem"
require "stm-task"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_ec1 = STMExternalConnection:new("stm_ec1", scheduler)

local stm_ml1 = STMMemoryLog:new("stm_ql1", scheduler)

local stm_st1 = STMSimpleTask:new("stm_st1", scheduler)

local event1 = Event:new(stm_ec1:id(), STMExternalConnection.events.CONNECT)

local event2 = Event:new(stm_ml1:id(), STMMemoryLog.events.START)

local event3 = Event:new(stm_st1:id(), STMSimpleTask.events.START)

scheduler:add_event(event1)
scheduler:add_event(event2)
scheduler:add_event(event3)
scheduler:run()