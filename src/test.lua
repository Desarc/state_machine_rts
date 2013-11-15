local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local task_repeats = {1, 50, 100, 500}
local measurements = 10

local time = {}
local current_size = 0
local current_repeats = 0

local function average()
	local sum = 0
	local count = 0
	for i,v in ipairs(time) do
		sum = sum + v
		count = count + 1
	end
	local average = sum/count
	return average
end

local function busy_work()
	for i=1,current_size do
		q = i*i
	end
end

for i=1,table.getn(task_repeats) do
	current_repeats = task_repeats[i]
	for j=1,table.getn(task_sizes) do
		current_size = task_sizes[j]
		for k=1,measurements do
			local start_time = tmr.read(tmr.SYS_TIMER)

			for l=1,current_repeats do
				busy_work()
			end

			local delta = tmr.read(tmr.SYS_TIMER) - start_time
			table.insert(time, delta)
			--print("Delta: "..tostring(delta))
		end
		print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(average()))
		time = {}
	end
end

--[[local task_size = 100000
local measurements = 5

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end

for i=1,measurements do
	local start_time = tmr.read(tmr.SYS_TIMER)

	simple_task()

	local delta = tmr.read(tmr.SYS_TIMER) - start_time
	print("Delta: "..tostring(delta))
end]]
