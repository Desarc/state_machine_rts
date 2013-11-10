Logger = {}


function Logger:log(data)
	self.file:write(data,'\n')
end

function Logger:close()
	self.file.close()
end

function Logger:new(filename)
	local o = {}
	setmetatable(o, { __index = self })
	print("Opening file "..filename)
	o.file = assert(io.open(filename, 'w'))
	return o
end