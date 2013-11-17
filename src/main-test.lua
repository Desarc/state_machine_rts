package.path = "/wo/?.lua;"..package.path

print("step: "..collectgarbage("setstepmul", 600))
--print("pause: "..collectgarbage("setpause", 110))

StateMachine = require "stm"
Scheduler = require "sched"
Event = require "event"
Timer = require "timer"
Message = require "msg"
STMBusyWork = require "stm-busy"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)

local event1 = Event:new(stm_bw1:id(), STMBusyWork.events.START)

scheduler:add_event(event1)
scheduler:run()
