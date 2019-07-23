require 'init'

-- lua
local os = require 'os'

--awesome
local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local root = require 'root'
local wibox = require 'wibox'

--local
local autorun = require 'autorun'
local keybindings = require 'keybindings'
local layout = require 'layout'
local widgets = require 'widgets'


local icons = {}
local boxes = {
  wi = {},
  prompt = {},
  layout = {},
}

-- setup all widgets to be drawn in layout
local widget_builder = widgets(beautiful, true)

-- add configured widget to layout on screens
layout(widget_builder.widgets, icons, boxes)

-- load keybindings
local binds = keybindings(boxes, widget_builder.widgets)

-- Set keys
root.keys(binds.global.keys)

require 'awful.autofocus'
--install client rules
awful.rules.rules = {
  -- All clients will match this rule.
  {rule = { },
  properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    keys = binds.client.keys,
    buttons = binds.client.buttons,
    size_hints_honor = false
  }},
}

local signals = require 'signals'
--autorun clients on start
autorun({ 
  ['google-chrome-unstable'] = {
    cmd=table.concat({
      '--enable-vulkan',
      '--process-per-site',
      '--high-dpi-support=1',
      '--force-device-scale-factor=2',
      '--touch-events=enabled',
      '--enable-native-gpu-memory-buffers',
      '--enable-zero-copy',
    }, ' '),
    match='chrome',
    rules={
      {
        rule = {class = 'google-chrome-unstable', class = 'Google-chrome-unstable'},
        callback = function(c)
          local s, t = 1, 2
          if screen.count() >= 2 then
            s, t = 2, 1
          end
          c:tags({widget_builder.widgets.tags:screen(s)[t]})
          c:geometry({
            width = screen[s].workarea.width,
            height = screen[s].workarea.height,
          })
        end,
      },
    },
  },
  ['alacritty'] = {
    cmd=table.concat({
      '-t Terminal',
      '-e '..os.getenv('HOME')..'/.config/awesome/tmux-session.sh awesome',
    }, ' '),
    rules={
      {
        rule = {class = 'alacritty'},
        properties = {
          tag = widget_builder.widgets.tags:screen(1)[1],
          width = screen[1].workarea.width,
          height = screen[1].workarea.height,
        },
      },
    },
  },
  ['udiskie'] = {},
  ['pulseaudio'] = {cmd='-D'},
  ['unclutter'] = {cmd='-root'},
  ['xautolock'] = {
    cmd=table.concat({
      '-time 5',
      '-detectsleep',
      '-locker /usr/local/bin/xautolocker',
    }, ' '),
  },
})
