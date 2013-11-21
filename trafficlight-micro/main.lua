package.path = "/wo/?.lua;"..package.path

local Scheduler = require "sched"
local Event = require "event"
local STMTrafficLight = require "stm-light"

local scheduler = Scheduler:new()

local stm_tl1 = STMTrafficLight:new("stm_tl1", scheduler)

local event1 = Event:new(stm_tl1.id(), STMTrafficLight.events.PEDESTRIAN_BUTTON_PRESSED)

scheduler.add_event(event1)
scheduler:run()	
