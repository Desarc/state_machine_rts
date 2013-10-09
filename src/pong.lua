
local function connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50000

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
	else
		print("Connected to " .. host_ip_str .. "!")
	end
	return socket
end

local function pong(socket)
	local res, err = net.recv(socket, "*l", 0)
	if err ~= 0 then
		print("Receive error: " .. err)
	elseif res ~= 0 then
		print("Message received: " .. res)
		res, err = net.send(socket, "pong.\n")
		if res == -1 then
			print("Send error: " .. err)
		end
	end
end

local socket = connect()

local time = tmr.read(tmr.SYS_TIMER)
local end_time = time+30000000

while time < end_time do
	pong(socket)
	time = tmr.read(tmr.SYS_TIMER)
end
