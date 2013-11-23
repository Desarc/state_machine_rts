package.path = "/wo/?.lua;"..package.path

require "msg"

local function connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50000
	net.connect(socket, host_ip, host_port)
	print("Connected to " .. host_ip_str .. "!")
	return socket
end

local socket = connect()
local msg

local function send_data(data)
	local message = Message:new({stm_id = "stm_l1", event_type = 2, user_data = data})
	local out_data = message:serialize()
	net.send(socket, out_data)
end

local deltas = {}

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

local message_sizes = {10, 100, 200, 500, 1000}
local no_measurements = 10
local current_size = 0
local start_time, delta = 0

local function time()
	return tmr.read(tmr.SYS_TIMER)
end

for j=1,table.getn(message_sizes) do
	current_size = message_sizes[j]
	for k=1,no_measurements do
		
		local data = {}
		for l=1,current_size do
			data[l] = "a"
		end
		msg = table.concat(data)

		start_time = time()

		send_data(msg)
		
		delta = time() - start_time
		table.insert(deltas, delta)
	end
	print(tostring(current_size)..": "..tostring(average()))
	for i in ipairs(deltas) do
		deltas[i] = nil
	end
end
