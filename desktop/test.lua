require "logger"

logger = Logger:new("busy_work.txt")

start = os.clock()
print(start)

local function busy_work()
	for i=1,10000000 do
		q = i*i
	end
	logger:log(tostring(os.clock()))
end


for i=1,500 do
	busy_work()
end

stop = os.clock()
print(stop)