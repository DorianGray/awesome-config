local mouse = require 'mouse'
local beautiful = require 'beautiful'
local root = require 'root'
local gears = require 'gears'
local awful = require 'awful'

local MOD = 'Mod4'
local ALT = 'Mod1'

local mt = {
  MOD=MOD,
  ALT=ALT,
}
mt.__index = mt

function mt:__call(boxes, widgets, tags)
  -- Key bindings
  local globalkeys = gears.table.join(unpack({
    -- screenshot
    awful.key({}, "Print", function ()
      awful.spawn.with_shell("sleep 0.5 && scrot -s")
    end), 

    awful.key({ALT, "Shift"}, "Tab", function ()
      widgets.alttab.switch(-1, ALT, "Tab", "ISO_Left_Tab")
    end),
    -- Default client focus
    awful.key({ALT}, 'k',
    function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
    awful.key({ALT}, 'j',
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),

    -- By direction client focus
    awful.key({MOD}, 'j',
    function()
      awful.client.focus.bydirection('down')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'k',
    function()
      awful.client.focus.bydirection('up')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'h',
    function()
      awful.client.focus.bydirection('left')
      if client.focus then client.focus:raise() end
    end),
    awful.key({MOD}, 'l',
    function()
      awful.client.focus.bydirection('right')
      if client.focus then client.focus:raise() end
    end),

    -- Show/Hide Wibox
    awful.key({MOD}, 'b', function ()
      boxes.wi[mouse.screen].visible = not boxes.wi[mouse.screen].visible
    end),
    -- Multi Monitor
    awful.key({}, "F8", function()
      widgets.display:show_tooltip()
    end),

    -- Layout manipulation
    awful.key({MOD, 'Shift'}, 'j', function ()
      awful.client.swap.byidx(1)
    end),
    awful.key({MOD, 'Shift'}, 'k', function ()
      awful.client.swap.byidx(-1)
    end),
    awful.key({MOD, 'Control'}, 'j', function ()
      awful.screen.focus_relative(1)
    end),
    awful.key({MOD, 'Control'}, 'k', function ()
      awful.screen.focus_relative(-1)
    end),
    awful.key({MOD,}, 'u', awful.client.urgent.jumpto),
    awful.key({MOD,}, 'Tab',
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),
    awful.key({MOD, 'Control'}, 'n',      awful.client.restore),

    -- Standard program
    awful.key({MOD, 'Control'}, 'r',      awesome.restart),
    awful.key({MOD, 'Shift'}, 'q',      awesome.quit),

    -- Lock screen
    awful.key({'Control', ALT}, 'l' , beautiful.command.lock),

    -- Prompt
    awful.key({MOD}, 'r', function () boxes.prompt[mouse.screen]:run() end),
    awful.key({MOD}, 'x',
    function ()
      awful.prompt.run({ prompt = 'Run Lua code: ' },
      boxes.prompt[mouse.screen].widget,
      gears.eval, nil,
      gears.getdir('cache') .. '/history_eval')
    end),
  }))

  for _, widget in pairs(widgets) do
    if type(widget) == 'table' and widget.keys then
      globalkeys = gears.table.join(globalkeys, unpack(widget.keys))
    end
  end

  local clientkeys = gears.table.join(
  awful.key({MOD,}, 'f', function (c) c.fullscreen = not c.fullscreen end),
  awful.key({ALT,}, 'F4', function (c) c:kill() end),
  awful.key({MOD,}, 'o', function (c) c:move_to_screen(s) end),
  awful.key({MOD,}, 't', function (c) c.ontop = not c.ontop end),
  awful.key({MOD,}, 'n', function (c) c.minimized = true end),
  awful.key({MOD,}, 'm', function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
  end)
  )

  return {
    client = {
      keys = clientkeys,
      buttons = {},
    },
    global = {
      keys = globalkeys,
      buttons = {},
    },
  }
end

return setmetatable({}, mt)
