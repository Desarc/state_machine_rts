

local function main()

	local ip = net.packip("192.168.100.90")
	print("IP: " .. ip)

	local host = net.lookup("DESARC-LAPTOP")
	print("Host: " .. host)

	local host_ip = net.packip("192.168.100.20")
	print("IP: " .. host_ip)

	local socket = net.socket(net.SOCK_STREAM)
	print("Socket: " .. socket)

	local port = 50000

	local err = net.connect(socket, host_ip, port)
	print("Connect error: " .. err)

	print("Send result: " .. res)
	print("Send error: " .. err)


	local res = net.close(socket)
	print("Close result: " .. res)

end

local function connect()
	local host_ip_str = "192.168.100.20"
	local host_ip = net.packip(host_ip_str)
	local socket = net.socket(net.SOCK_STREAM)
	local host_port = 50001

	local err = net.connect(socket, host_ip, host_port)

	if err ~= 0 then
		print("Connect error: " .. err)
	else
		print("Connected to " .. host_ip_str .. "!")
	end
	return socket
end


local function buffered_receive(socket)

	local time = tmr.read(tmr.SYS_TIMER)
	local end_time = time+30000000

	while time < end_time do
		time = tmr.read(tmr.SYS_TIMER)
	end

	local res, err = net.recv(socket, "*l", 0)
	if err ~= 0 then
		print("Receive error: " .. err)
	elseif res ~= 0 then
		print("Message received: " .. res)
	end
end

local socket = connect()

buffered_receive(socket)

--main()