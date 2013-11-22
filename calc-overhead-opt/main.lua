package.path = "/wo/?.lua;"..package.path

print(collectgarbage("setstepmul", 600))

require "timer"
require "sched"
require "event"
require "stm"
require "stm-calc"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_pt1 = STMPerformanceTester:new("stm_pt1", scheduler)

local event1 = Event:new(stm_pt1.id, STMPerformanceTester.events.START)

scheduler:add_event(event1)
scheduler:run()
