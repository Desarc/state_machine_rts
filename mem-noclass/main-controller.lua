package.path = "/wo/?.lua;"..package.path

print(collectgarbage("setstepmul", 600))

require "timer"
require "sched"
require "event"
require "msg"
require "stm"
require "stm-tcp-client"
require "stm-mem"
require "stm-task"

Scheduler:set_up(Scheduler.type.CONTROLLER)

STMTcpClient:set_up("stm_tc1", Scheduler)

STMMemoryLogger:set_up("stm_ql1", Scheduler)

STMSimpleTask:set_up("stm_st1", Scheduler)

event1 = Event:new(STMTcpClient.id, STMTcpClient.events.CONNECT)

event2 = Event:new(STMMemoryLogger.id, STMMemoryLogger.events.START)

event3 = Event:new(STMSimpleTask.id, STMSimpleTask.events.START)

--Scheduler:add_event(event1)
--Scheduler:add_event(event2)
--Scheduler:add_event(event3)
Scheduler:run()
