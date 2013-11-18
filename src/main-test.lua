package.path = "/wo/?.lua;"..package.path

--print("step: "..collectgarbage("setstepmul", 600))
--print("pause: "..collectgarbage("setpause", 110))

require "stm"
require "sched"
require "event"
require "timer"
require "msg"
--require "stm-busy"
require "stm-led"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

--local stm_bw1 = STMBusyWork:new("stm_bw1", scheduler)

local stm_led1 = STMLED:new("stm_led1", scheduler)

local event1 = Event:new(stm_led1:id(), STMLED.events.INIT)

local event2 = Event:new(stm_led1:id(), STMLED.events.SET_ON)

scheduler:add_event(event1)
scheduler:add_event(event2)
scheduler:run()
