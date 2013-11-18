package.path = "/wo/?.lua;"..package.path

require "test"

local test = Test:new()

test.run()