--[[local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local task_repeats = {1, 50, 100, 500}
local measurements = 10

local time = {}
local current_size = 0

local start_time = 0

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

local function simple_task()
	for i=1,current_size do
		q = i*i
	end
end

for i=1,table.getn(task_repeats) do
	local current_repeats = task_repeats[i]
	for j=1,table.getn(task_sizes) do
		current_size = task_sizes[j]
		for k=1,measurements do
			start_time = tmr.read(tmr.SYS_TIMER)

			for l=1,current_repeats do
				simple_task()
			end

			local delta = tmr.read(tmr.SYS_TIMER) - start_time
			table.insert(time, delta)
		end
		print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(average()))
		time = {}
	end
end]]

Test = {}

function Test:new ()
	local o = {}
	setmetatable(o, { __index = self })
	local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
	local measurements = 10

	local deltas = {}
	local current_size = 0

	local function average()
		local sum = 0
		local count = 0
		for i,v in ipairs(deltas) do
			sum = sum + v
			count = count + 1
		end
		local average = sum/count
		return average
	end

	local function simple_task()
		for i=1,current_size do
			q = i*i
		end
	end

	local function time()
		return tmr.read(tmr.SYS_TIMER)
	end

	o.run = function ()
		local start_time = 0
		for j=1,table.getn(task_sizes) do
			current_size = task_sizes[j]
			for k=1,measurements do
				start_time = time()

				simple_task()

				local delta = time() - start_time
				table.insert(deltas, delta)
			end
			print(tostring(current_size)..": "..tostring(average()))
			deltas = {}
		end
	end

	return o
end

return Test