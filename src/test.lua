local task_size = 10
local task_repeats = 1
local measurements = 5

local function busy_work()
	for i=1,task_size do
		q = i*i
	end
end

for i=1,measurements do
	local start_time = tmr.read(tmr.SYS_TIMER)

	for j=1,task_repeats do
		busy_work()
	end

	local delta = tmr.read(tmr.SYS_TIMER) - start_time
	print("Delta: "..tostring(delta))
end