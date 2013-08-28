require "luaproc"

luaproc.createworker()

luaproc.newproc ( [==[
	luaproc.newchannel("test")

	luaproc.newproc( [=[
		luaproc.send("test", "hello world")
	]=])

	luaproc.newproc( [=[
		msg = luaproc.receive("test")
		print(msg)
	]=])
]==])

luaproc.exit()