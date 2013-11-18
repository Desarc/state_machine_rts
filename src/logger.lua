local Logger = {}

-- this object is not run on the microcontroller, so we can use encapsulation
function Logger:new(filename)
	local o = {}
	--setmetatable(o, { __index = self })
	print("Opening file "..filename)
	local file = assert(io.open(filename, 'w'))

	o.log = function (data)
		file:write(data,'\n')
	end

	o.close = function ()
		file.close()
	end

	return o
end

return Logger