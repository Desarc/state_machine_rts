package.path = "/wo/?.lua;"..package.path

--print(collectgarbage("setpause", 110))
print(collectgarbage("setstepmul", 1000))

require "timer"
require "sched"
require "event"
require "msg"
require "stm"
require "stm-tcp-client"
require "stm-mem"
require "stm-task"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_tc1 = STMTcpClient:new("stm_tc1", scheduler)

local stm_ml1 = STMMemoryLogger:new("stm_ql1", scheduler)

local stm_st1 = STMSimpleTask:new("stm_st1", scheduler)

local event1 = Event:new(stm_tc1.id, STMTcpClient.events.CONNECT)

local event2 = Event:new(stm_ml1.id, STMMemoryLogger.events.START)

local event3 = Event:new(stm_st1.id, STMSimpleTask.events.START)

scheduler:add_event(event1)
scheduler:add_event(event2)
scheduler:add_event(event3)
scheduler:run()
