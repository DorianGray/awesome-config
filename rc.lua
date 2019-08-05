require 'init'

-- lua
local os = require 'os'

--awesome
local awful = require 'awful'
local beautiful = require 'beautiful'
local root = require 'root'
local wibox = require 'wibox'

--local
local autorun = require 'util.autorun'
local keybindings = require 'keybindings'
local widget = require 'widget'

local unpack = table.unpack or unpack


-- setup all widgets to be drawn in layout
local w = {
  wibar = widget.wibar(),
  layout = widget.layout,
  tag = widget.tag(),
  task = widget.task(),
  clock = wibox.widget.textclock('%H:%M'),
  calendar = awful.widget.calendar_popup.month({
    font=beautiful.font,
    start_sunday=true,
  }),
  alttab = widget.alttab,
  battery = widget.battery(beautiful.battery),
  volume = widget.volume,
  network = widget.net(),
  power = widget.power,
  display = widget.display,
} 
w.calendar:attach(w.clock, "tr")

-- Wibar setup, one per screen
for s in screen do
  local wibar = w.wibar:widget(s)

  wibar.layout.left:add(w.layout(s))
  wibar.layout.left:add(w.tag:widget(s))

  --systray only on primary screen
  if s.index == 1 then wibar.layout.right:add(wibox.widget.systray()) end
  wibar.layout.right:add(w.display)
  wibar.layout.right:add(w.volume)
  wibar.layout.right:add(w.network.widget)
  wibar.layout.right:add(w.battery)
  wibar.layout.right:add(w.clock)
  wibar.layout.right:add(w.power)

  wibar.layout.middle:add(w.task:widget(s))
end

-- load keybindings
local binds = keybindings()

--install default client rules
table.insert(awful.rules.rules, {
  rule={},
  properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    keys = binds.client,
    size_hints_honor = false,
  },
})

-- Set widget specific keys
for _, widget in pairs(w) do
  if type(widget) == 'table' and widget.keys then
    binds:register('global', widget.keys)
  end
end

root.keys(binds.global)
-- register global signal handlers
require 'signals'
--autorun clients on start
autorun({ 
  ['google-chrome-unstable'] = {
    args={
      '--enable-vulkan',
      '--process-per-site',
      '--high-dpi-support=1',
      '--force-device-scale-factor=2',
      '--touch-events=enabled',
      '--enable-native-gpu-memory-buffers',
      '--enable-zero-copy',
    },
    match='chrome',
    rules={
      {
        rule = {class = 'google-chrome-unstable', class = 'Google-chrome-unstable'},
        callback = function(c)
          local s, t = 1, 2
          if screen.count() >= 2 then
            s, t = 2, 1
          end
          c:tags({w.tag:screen(s)[t]})
          c:geometry({
            width = screen[s].workarea.width,
            height = screen[s].workarea.height,
          })
        end,
      },
    },
  },
  ['alacritty'] = {
    args={
      '-t Terminal',
      '-e '..os.getenv('HOME')..'/.config/awesome/tmux-session.sh awesome',
    },
    rules={
      {
        rule = {class = 'alacritty'},
        properties = {
          tag = w.tag:screen(1)[1],
          width = screen[1].workarea.width,
          height = screen[1].workarea.height,
        },
      },
    },
  },
  ['udiskie'] = {},
  ['pulseaudio'] = {args={'-D'}},
  ['unclutter'] = {args={'-root'}},
  ['xautolock'] = {
    args={
      '-time 5',
      '-detectsleep',
      '-locker /usr/local/bin/xautolocker',
    },
  },
})
