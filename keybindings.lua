local mouse = require 'mouse'
local beautiful = require 'beautiful'
local root = require 'root'
local gears = require 'gears'
local awful = require 'awful'
local process = require 'awful.io.process'

local unpack = table.unpack or unpack

local MOD = 'Mod4'
local ALT = 'Mod1'
local SHIFT = 'Shift'
local CONTROL = 'Control'
local TAB = TAB

local mt = {
  MOD=MOD,
  ALT=ALT,
  SHIFT=SHIFT,
  CONTROL=CONTROL,
  TAB=TAB,
}
mt.__index = mt

function mt:__call()
  -- Key bindings
  local globalkeys = gears.table.join(unpack({
    -- screenshot
    awful.key({}, "Print", function ()
      process.run("sleep 0.5 && scrot -s")
    end), 
 
    -- Default client focus
    awful.key({ALT}, 'k', function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
    awful.key({ALT}, 'j', function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),

    -- By direction client focus
    awful.key({MOD}, 'j', function()
      awful.client.focus.bydirection('down')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'k', function()
      awful.client.focus.bydirection('up')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'h', function()
      awful.client.focus.bydirection('left')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'l', function()
      awful.client.focus.bydirection('right')
      if client.focus then client.focus:raise() end
    end),

    awful.key({}, "XF86MonBrightnessDown", function () process.run("xbacklight -dec 5") end),
    awful.key({}, "XF86MonBrightnessUp", function () process.run("xbacklight -inc 5") end),

    -- Layout manipulation
    awful.key({MOD, SHIFT}, 'j', function ()
      awful.client.swap.byidx(1)
    end),
    awful.key({MOD, SHIFT}, 'k', function ()
      awful.client.swap.byidx(-1)
    end),
    awful.key({MOD, CONTROL}, 'j', function ()
      awful.screen.focus_relative(1)
    end),
    awful.key({MOD, CONTROL}, 'k', function ()
      awful.screen.focus_relative(-1)
    end),
    awful.key({MOD,}, 'u', awful.client.urgent.jumpto),
    awful.key({MOD,}, TAB, function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),
    awful.key({MOD, CONTROL}, 'n', awful.client.restore),

    -- Standard program
    awful.key({MOD, CONTROL}, 'r', awesome.restart),
    awful.key({MOD, SHIFT}, 'q', awesome.quit),

    -- Lock screen
    awful.key({CONTROL, ALT}, 'l', beautiful.command.lock), 
  }))

  local clientkeys = gears.table.join(unpack({
    awful.key({MOD,}, 'f', function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ALT,}, 'F4', function (c) c:kill() end),
    awful.key({MOD,}, 'o', function (c) c:move_to_screen(s) end),
    awful.key({MOD,}, 't', function (c) c.ontop = not c.ontop end),
    awful.key({MOD,}, 'n', function (c) c.minimized = true end),
    awful.key({MOD,}, 'm', function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end)
  }))

  local data = {
    client = clientkeys,
    global = globalkeys,
  }
  function data:register(namespace, keys)
    self[namespace] = gears.table.join(self[namespace], unpack(keys))
  end
  return data
end

return setmetatable({}, mt)
