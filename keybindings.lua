local mouse = require 'mouse'
local beautiful = require 'beautiful'
local root = require 'root'
local gears = require 'gears'
local awful = require 'awful'

local modkey = 'Mod4'
local altkey = 'Mod1'

return function(boxes, widgets, tags)
  -- Key bindings
  local globalkeys = gears.table.join(unpack({
    -- screenshot
    awful.key({}, "Print", function ()
      awful.spawn.with_shell("sleep 0.5 && scrot -s")
    end), 

    awful.key({altkey, "Shift"}, "Tab", function ()
      widgets.alttab.switch(-1, altkey, "Tab", "ISO_Left_Tab")
    end),
    -- Default client focus
    awful.key({altkey}, 'k',
    function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
    awful.key({altkey}, 'j',
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),

    -- By direction client focus
    awful.key({modkey}, 'j',
    function()
      awful.client.focus.bydirection('down')
      if client.focus then client.focus:raise() end
    end),
    awful.key({modkey}, 'k',
    function()
      awful.client.focus.bydirection('up')
      if client.focus then client.focus:raise() end
    end),
    awful.key({modkey}, 'h',
    function()
      awful.client.focus.bydirection('left')
      if client.focus then client.focus:raise() end
    end),
    awful.key({modkey}, 'l',
    function()
      awful.client.focus.bydirection('right')
      if client.focus then client.focus:raise() end
    end),

    -- Show/Hide Wibox
    awful.key({modkey}, 'b', function ()
      boxes.wi[mouse.screen].visible = not boxes.wi[mouse.screen].visible
    end),
    -- Multi Monitor
    awful.key({}, "F8", function()
      widgets.display:show_tooltip()
    end),

    -- Layout manipulation
    awful.key({modkey, 'Shift'}, 'j', function ()
      awful.client.swap.byidx(1)
    end),
    awful.key({modkey, 'Shift'}, 'k', function ()
      awful.client.swap.byidx(-1)
    end),
    awful.key({modkey, 'Control'}, 'j', function ()
      awful.screen.focus_relative(1)
    end),
    awful.key({modkey, 'Control'}, 'k', function ()
      awful.screen.focus_relative(-1)
    end),
    awful.key({modkey,}, 'u', awful.client.urgent.jumpto),
    awful.key({modkey,}, 'Tab',
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),
    awful.key({modkey, 'Control'}, 'n',      awful.client.restore),

    -- Standard program
    awful.key({modkey, 'Control'}, 'r',      awesome.restart),
    awful.key({modkey, 'Shift'}, 'q',      awesome.quit),

    -- Lock screen
    awful.key({'Control', altkey}, 'l' , beautiful.command.lock),

    -- Prompt
    awful.key({modkey}, 'r', function () boxes.prompt[mouse.screen]:run() end),
    awful.key({modkey}, 'x',
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
  awful.key({modkey,}, 'f', function (c) c.fullscreen = not c.fullscreen end),
  awful.key({altkey,}, 'F4', function (c) c:kill() end),
  awful.key({modkey,}, 'o', function (c) c:move_to_screen(s) end),
  awful.key({modkey,}, 't', function (c) c.ontop = not c.ontop end),
  awful.key({modkey,}, 'n', function (c) c.minimized = true end),
  awful.key({modkey,}, 'm', function (c)
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
