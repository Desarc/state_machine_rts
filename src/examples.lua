a = "one string"
b = string.gsub(a, "one", "another")  -- change string parts
print(a)       --> one string
print(b)       --> another string

--[[
print(10)         -- no action (comment)
--]]
    
print(b)  --> nil
b = 10
print(b)  --> 10

b = nil
print(b)  --> nil


-- defines a factorial function
function fact (n)
  if n == 0 then
    return 1
  else
    return n * fact(n-1)
  end
end

print("enter a number:")
a = io.read("*number")        -- read a number
print(fact(a))

page = [[
	<HTML>
	<HEAD>
	<TITLE>An HTML Page</TITLE>
	</HEAD>
	<BODY>
	 <A HREF="http://www.lua.org">Lua</A>
	 [[a text between double brackets]]
	</BODY>
	</HTML>
	]]

line = io.read()     -- read a line
n = tonumber(line)   -- try to convert it to a number
if n == nil then
  error(line .. " is not a valid number")
else
  print(n*2)
end

-- read 10 lines storing them in a table
    a = {}
    for i=1,10 do
      a[i] = io.read()
    end
    
a = {}
    x = "y"
    a[x] = 10                 -- put 10 in field "y"
    print(a[x])   --> 10      -- value of field "y"
    print(a.x)    --> nil     -- value of field "x" (undefined)
    print(a.y)    --> 10      -- value of field "y"
    
A useful Lua idiom is x = x or v, which is equivalent to

    if not x then x = v end
    
Another useful idiom is (a and b) or c (or simply a and b or c, because and has a higher precedence than or), which is equivalent to the C expression

    a ? b : c
    
    provided that b is not false.
    
  print("Hello " .. "World")  --> Hello World
  
  list = nil
    for line in io.lines() do
      list = {next=list, value=line}
    end
    
    
    polyline = {color="blue", thickness=2, npoints=4,
                 {x=0,   y=0},
                 {x=-10, y=0},
                 {x=-10, y=1},
                 {x=0,   y=1}
               }
               
starts at index 1 
              
opnames = {["+"] = "add", ["-"] = "sub",
               ["*"] = "mul", ["/"] = "div"}
               
               
{x=10, y=45; "one", "two", "three"}

a, b = 10, 2*x

x, y = y, x                -- swap `x' for `y'
    a[i], a[j] = a[j], a[i]    -- swap `a[i]' for `a[j]'
    
a, b, c = 0
    print(a,b,c)           --> 0   nil   nil
    
a, b = f()

Moreover, the access to local variables is faster than to global ones.

do
      local a2 = 2*a
      local d = sqrt(b^2 - 4*a*c)
      x1 = (-b + d)/a2
      x2 = (-b - d)/a2
    end          -- scope of `a2' and `d' ends here
    print(x1, x2)
    
 -- print the first non-empty line
    repeat
      line = os.read()
    until line ~= ""
    print(line)
    
If you need the value of the control variable after the loop (usually when you break the loop), you must save this value into another variable:
    -- find a value in a list
    local found = nil
    for i=1,a.n do
      if a[i] == value then
        found = i      -- save value of `i'
        break
      end
    end
    print(found)
Third, you should never change the value of the control variable: The effect of such changes is unpredictable. If you want to break a for loop before its normal termination, use break.

 -- print all values of array `a'
    for i,v in ipairs(a) do print(v) end
For each step in that code, i gets an index, while v gets the value associated with that index. A similar example shows how we traverse all keys of a table:
    -- print all keys of table `t'
    for k in pairs(t) do print(k) end
    
    
An expression like o:foo(x) is just another way to write o.foo(o, x)

print "Hello World"     <-->     print("Hello World")
    dofile 'a.lua'          <-->     dofile ('a.lua')
    print [[a multi-line    <-->     print([[a multi-line
     message]]                        message]])
    f{x=10, y=20}           <-->     f({x=10, y=20})
    type{}                  <-->     type({})
    
f(3)             a=3, b=nil
    f(3, 4)          a=3, b=4
    f(3, 4, 5)       a=3, b=4   (5 is discarded)
    
    
print(unpack{10,20,30})    --> 10   20   30
    a,b = unpack{10,20,30}     -- a=10, b=20, 30 is discarded
    
f = string.find
    a = {"hello", "ll"}
then the call f(unpack(a)) returns 3 and 4, exactly the same as the static call string.find("hello", "ll").

printResult = ""
    
    function print (...)
      for i,v in ipairs(arg) do
        printResult = printResult .. tostring(v) .. "\t"
      end
      printResult = printResult .. "\n"
    end
    
local _, x = string.find(s, p)
    -- now use `x'
    ...
    
 function g (a, b, ...) end
 
 rename{old="temp.lua", new="temp1.lua"}
 
 function rename (arg)
      return os.rename(arg.old, arg.new)
    end
    
function Window (options)
      -- check mandatory options
      if type(options.title) ~= "string" then
        error("no title")
      elseif type(options.width) ~= "number" then
        error("no width")
      elseif type(options.height) ~= "number" then
        error("no height")
      end
    
      -- everything else is optional
      _Window(options.title,
              options.x or 0,    -- default value
              options.y or 0,    -- default value
              options.width, options.height,
              options.background or "white",   -- default
              options.border      -- default is false (nil)
             )
    end
    
a = {p = print}
    a.p("Hello World") --> Hello World
    print = math.sin  -- `print' now refers to the sine function
    a.p(print(1))     --> 0.841470
    sin = a.p         -- `sin' now refers to the print function
    sin(10, 20)       --> 10      20
    
    
    
function foo (x) return 2*x end
is just an instance of what we call syntactic sugar; in other words, it is just a pretty way to write
    foo = function (x) return 2*x end
    
table.sort(network, function (a,b)
      return (a.name > b.name)
    end)
    
do
      local oldSin = math.sin
      local k = math.pi/180
      math.sin = function (x)
        return oldSin(x*k)
      end
    end
    
You can use this same feature to create secure environments, also called sandboxes. Secure environments are essential when running untrusted code, such as code received through the Internet by a server. For instance, to restrict the files a program can access, we can redefine the open function (from the io library) using closures:

    do
      local oldOpen = io.open
      io.open = function (filename, mode)
        if access_OK(filename, mode) then
          return oldOpen(filename, mode)
        else
          return nil, "access denied"
        end
      end
    end
    
Lib = {}
    function Lib.foo (x,y)
      return x + y
    end
    function Lib.goo (x,y)
      return x - y
    end
    
    
function list_iter (t)
      local i = 0
      local n = table.getn(t)
      return function ()
               i = i + 1
               if i <= n then return t[i] end
             end
    end
    
t = {10, 20, 30}
    for element in list_iter(t) do
      print(element)
    end