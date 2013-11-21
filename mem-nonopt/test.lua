package.path = "/wo/?.lua;"..package.path

require "msg"

local function connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50000

	local err = net.connect(socket, host_ip, host_port)
	print("Connected to " .. host_ip_str .. "!")
	return socket
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
	local data = ""
	for i,v in ipairs(measurements) do
		data = data..tostring(v).." "
	end
	send_data(data)
	measurements = {}
end
