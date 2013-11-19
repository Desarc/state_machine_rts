local Scheduler = require "sched"
local Event = require "event"
local STMPrintMessage = require "stm-print"

local scheduler = Scheduler:new()

local stm_pm1 = STMPrintMessage:new("stm_pm1", scheduler)

local event1 = Event:new(stm_pm1.id(), STMPrintMessage.events.PEDESTRIAN_BUTTON_PRESSED)

scheduler.add_event(event1)
scheduler:run()	
