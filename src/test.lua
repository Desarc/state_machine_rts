package.path = "/wo/?.lua;"..package.path

--[[local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
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
			table.insert(deltas, delta)
		end
		print(tostring(current_size).."/"..tostring(current_repeats)..": "..tostring(average()))
		for i,v in ipairs(deltas) do
			deltas[i] = nil
		end
	end
end]]


--[[local task_sizes = {10, 50, 100, 500, 1000, 5000, 10000, 50000}
local measurements = 10

local deltas = {}
local current_size = 0

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
		for i,v in ipairs(deltas) do
			deltas[i] = nil
		end
	end
end]]
require "msg"

print("step: "..collectgarbage("setstepmul", 600))

local function connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50001

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
		return nil
	else
		print("Connected to " .. host_ip_str .. "!")
		return socket
	end
end

local socket = connect()

local function send_data(data)
	local message = Message:new({stm_id = "stm_l1", event_type = 2, user_data = data})
	local out_data = message:serialize()
	print("Sending data...")
	local res, err = net.send(socket, out_data)
	if err ~= 0 then
		return res, err
	end
end

local task_size = 500
local task_repeats = 20
local no_measurements = 10
local run_time = 300

local measurements = {}

local function simple_task()
	for i=1,task_size do
		q = i*i
	end
end

for i=1,run_time do
	for k=1,no_measurements do

		for l=1,task_repeats do
			simple_task()
		end

		local mem = collectgarbage("count")
		table.insert(measurements, mem)
	end
	send_data(table.concat(measurements, " "))
	for j,v in ipairs(measurements) do
		measurements[j] = nil
	end
end
