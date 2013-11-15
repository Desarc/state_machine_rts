package.path = "/wo/?.lua;"..package.path

local Test = require "test"

local test = Test:new()

test.run()