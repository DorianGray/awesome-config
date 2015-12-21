local awful = require 'awful'
local lain = require 'lain'
local DIR = require 'pl.path'.dirname(debug.getinfo(1,'S').source:sub(2))

local layouts    = require 'layouts'
local modkey     = 'Mod4'
local altkey     = 'Mod1'

return function(boxes, widgets)
  -- Key bindings
  local globalkeys = awful.util.table.join(

  awful.key({ altkey }, 'p', function() awful.spawn.with_shell('gnome-screenshot -c') end),

  -- Tag browsing
  awful.key({ modkey }, 'Left',   awful.tag.viewprev       ),
  awful.key({ modkey }, 'Right',  awful.tag.viewnext       ),
  awful.key({ modkey }, 'Escape', awful.tag.history.restore),

  -- Non-empty tag browsing
  awful.key({ altkey }, 'Left', function () lain.util.tag_view_nonempty(-1) end),
  awful.key({ altkey }, 'Right', function () lain.util.tag_view_nonempty(1) end),
  -- Alt Tab
  awful.key({ altkey }, "Tab",
  function ()
    widgets.alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
  end	     
  ),

  awful.key({ altkey, "Shift"   }, "Tab",
  function ()
    widgets.alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
  end
  ),
  -- Default client focus
  awful.key({ altkey }, 'k',
  function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ altkey }, 'j',
  function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),

  -- By direction client focus
  awful.key({ modkey }, 'j',
  function()
    awful.client.focus.bydirection('down')
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, 'k',
  function()
    awful.client.focus.bydirection('up')
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, 'h',
  function()
    awful.client.focus.bydirection('left')
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, 'l',
  function()
    awful.client.focus.bydirection('right')
    if client.focus then client.focus:raise() end
  end),

  -- Show/Hide Wibox
  awful.key({ modkey }, 'b', function ()
    boxes.wi[mouse.screen].visible = not boxes.wi[mouse.screen].visible
  end),
  -- Multi Monitor
  awful.key({}, "XF86Display", require 'xrandr'),
  -- Layout manipulation
  awful.key({ modkey, 'Shift'   }, 'j', function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, 'Shift'   }, 'k', function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, 'Control' }, 'j', function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, 'Control' }, 'k', function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, 'u', awful.client.urgent.jumpto),
  awful.key({ modkey,           }, 'Tab',
  function ()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end),
  awful.key({ altkey, 'Shift'   }, 'l',      function () awful.tag.incmwfact( 0.05)     end),
  awful.key({ altkey, 'Shift'   }, 'h',      function () awful.tag.incmwfact(-0.05)     end),
  awful.key({ modkey, 'Shift'   }, 'l',      function () awful.tag.incnmaster(-1)       end),
  awful.key({ modkey, 'Shift'   }, 'h',      function () awful.tag.incnmaster( 1)       end),
  awful.key({ modkey, 'Control' }, 'l',      function () awful.tag.incncol(-1)          end),
  awful.key({ modkey, 'Control' }, 'h',      function () awful.tag.incncol( 1)          end),
  awful.key({ modkey,           }, 'space',  function () awful.layout.inc(layouts,  1)  end),
  awful.key({ modkey, 'Shift'   }, 'space',  function () awful.layout.inc(layouts, -1)  end),
  awful.key({ modkey, 'Control' }, 'n',      awful.client.restore),

  -- Standard program
  awful.key({ modkey, 'Control' }, 'r',      awesome.restart),
  awful.key({ modkey, 'Shift'   }, 'q',      awesome.quit),

  -- Brightness
  awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn("xbacklight -dec 3") end),
  awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn("xbacklight -inc 3") end),

  -- Audio
  awful.key({ }, "XF86AudioRaiseVolume",  widgets.volume.Up),
  awful.key({ }, "XF86AudioLowerVolume",  widgets.volume.Down),
  awful.key({ }, "XF86AudioMute",         widgets.volume.ToggleMute),

  awful.key({ }, "XF86PowerOff", function() widgets.power.menu:toggle({coords={x=1845,y=0}}) end),
  -- Lock screen
  awful.key({'Control', altkey}, 'l' , function ()
    local command = 'gnome-screensaver-command -l'
    awful.spawn.with_shell(command)
  end),

  -- Copy to clipboard
  awful.key({ modkey }, 'c', function () os.execute('xsel -p -o | xsel -i -b') end),

  -- Prompt
  awful.key({ modkey }, 'r', function () boxes.prompt[mouse.screen]:run() end),
  awful.key({ modkey }, 'x',
  function ()
    awful.prompt.run({ prompt = 'Run Lua code: ' },
    boxes.prompt[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir('cache') .. '/history_eval')
  end))

  clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, 'f',      function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, 'Shift'   }, 'c',      function (c) c:kill()                         end),
  awful.key({ modkey, 'Control' }, 'space',  awful.client.floating.toggle                     ),
  awful.key({ modkey, 'Control' }, 'Return', function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,           }, 'o',      awful.client.movetoscreen                        ),
  awful.key({ modkey,           }, 't',      function (c) c.ontop = not c.ontop            end),
  awful.key({ modkey,           }, 'n',
  function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end),
  awful.key({ modkey,           }, 'm',
  function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
  end)
  )

  -- Bind all key numbers to tags.
  -- be careful: we use keycodes to make it works on any keyboard layout.
  -- This should map on the top row of your keyboard, usually 1 to 9.
  for i = 1, 9 do
    local globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, '#' .. i + 9,
    function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewonly(tag)
      end
    end),
    -- Toggle tag.
    awful.key({ modkey, 'Control' }, '#' .. i + 9,
    function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end),
    -- Move client to tag.
    awful.key({ modkey, 'Shift' }, '#' .. i + 9,
    function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.movetotag(tag)
        end
      end
    end),
    -- Toggle tag.
    awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9,
    function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.toggletag(tag)
        end
      end
    end))
  end

  local clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

  -- Set keys
  root.keys(globalkeys)
end
