
print("This is a test.")

Message = dofile("message.lua")

message = Message:new({title="hello", time="12:30", number=12})

print(message:lookup("title"))

print(message:content_index())

str = message:serialize()

print(str)

message2 = Message.deserialize(str)

print(message2:content_index())

Test = {}

function help(table)
	for k,v in ipairs(table) do
		print(k..v)
	end
end

help({test1="huh", test2="hm"})