local Logger = {}

function Logger:new(filename)
	local o = {}
	print("Opening file "..filename)
	local file = assert(io.open(filename, 'w'))

	o.log = function (data)
		file:write(data, '\n')
	end

	o.close = function ()
		file.close()
	end

	return o
end

return Logger