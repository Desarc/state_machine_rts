package.path = "/wo/?.lua;"..package.path

local Scheduler = require "sched"
local Event = require "event"
local STMPerformanceTester = require "stm-calc"

local scheduler = Scheduler:new(Scheduler.type.CONTROLLER)

local stm_pt1 = STMPerformanceTester:new("stm_pt1", scheduler)

local event1 = Event:new(stm_pt1.id(), STMPerformanceTester.events.START)

scheduler.add_event(event1)
scheduler:run()	
