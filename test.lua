package.path = os.getenv('HOME')..'/.luarocks/share/lua/5.1/?.lua;'..os.getenv('HOME')..'/.luarocks/share/lua/5.1/?/init.lua;'..package.path
package.cpath = os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?.so;'..os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?/init.so;'..package.cpath

local lanes = require "lanes"
lanes.configure()

local linda = lanes.linda()

local function loop( max)
  for i = 1, max do
    linda:send( "x", i)
  end
end

local a = lanes.gen( "", loop)(3)

while true do
  local key, val = linda:receive( 3.0, "x")    -- timeout in seconds
  if val == nil then
    print( "timed out")
    break
  end
  print( tostring( linda) .. " received: " .. val)
end
