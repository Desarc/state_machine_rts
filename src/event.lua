Event = {}

function Event:state_machine()
	return self.data.state_machine
end

function Event:type()
	return self.data.type
end

function Event:new(state_machine, type)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.data = {state_machine = state_machine, type = type}
	return o
end