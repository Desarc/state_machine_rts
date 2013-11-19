local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local task_repeats = {1, 50, 100, 500}
local measurements = 10

local deltas = {}
local current_size = 0

local start_time = 0

local function average()
	local sum = 0
	local count = 0
	for i,v in ipairs(deltas) do
		sum = sum + v
		count = i
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

for i=1,table.getn(task_repeats) do
	local current_repeats = task_repeats[i]
	for j=1,table.getn(task_sizes) do
		current_size = task_sizes[j]
		for k=1,measurements do
			start_time = time()

			for l=1,current_repeats do
				simple_task()
			end

			local delta = time() - start_time
			table.insert(deltas, delta)
		end
		print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(average()))
		for i,v in ipairs(deltas) do
			deltas[i] = nil
		end
	end
end
