local gears     = require 'gears'
local awful     = require 'awful'
awful.rules     = require 'awful.rules'
require 'awful.autofocus'
local wibox     = require 'wibox'
local beautiful = require 'beautiful'
local naughty   = require 'naughty'
local lain      = require 'lain'
local layouts   = require 'layouts'
local theme     = require 'theme'

-- Error handling
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = awesome.startup_errors,
  })
end

local in_error = false
awesome.connect_signal('debug::error', function (err)
  if in_error then return end
  in_error = true

  naughty.notify({
    preset = naughty.config.presets.critical,
    title = 'Oops, an error occurred!',
    text = debug.traceback(err),
  })
  in_error = false
end)

-- beautiful init
beautiful.init(os.getenv('HOME') .. '/.config/awesome/theme/init.lua')

-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

local widgets = {}
local icons = {}
local boxes = {
  wi = {},
  prompt = {},
  layout = {},
}
local taglist = {}

-- Textclock
widgets.clock = lain.widgets.abase({
  timeout  = 60,
  cmd      = 'date +\'%R\'',
  settings = function()
    widget:set_text(' ' .. output)
  end
})

-- calendar
widgets.calendar = lain.widgets.calendar
widgets.calendar:attach(widgets.clock, {
  font = 'Inconsolata Bold',
  font_size = theme.font_size,
})

--Alt Tab
widgets.alttab = require 'widget.alttab'
widgets.alttab.settings.preview_box = true
widgets.alttab.settings.preview_box_bg = "#ddddddaa"
widgets.alttab.settings.preview_box_border = "#22222200"
widgets.alttab.settings.preview_box_fps = 30
widgets.alttab.settings.preview_box_delay = 150

widgets.alttab.settings.client_opacity = false
widgets.alttab.settings.client_opacity_value = 0.5
widgets.alttab.settings.client_opacity_delay = 150

-- Battery
widgets.battery = require 'widget.battery'({
  width = 30,
  height = 10,
  bolt_width = 30,
  bolt_height = 15,
  stroke_width = 2,
  peg_top = 4,
  peg_height = 6,
  peg_width = 4,
  font = beautiful.font,
  critical_level = 0.10,
  normal_color = beautiful.fg_normal,
  critical_color = beautiful.fg_urgent,
  charging_color = beautiful.fg_normal,
})

-- Audio
widgets.volume = require 'widget.volume'

-- Net
widgets.network = require 'widget.net'.widget(boxes.prompt)

-- Power
widgets.power = require 'widget.power'

-- Display
widgets.display = require 'widget.display'

require 'layout'(widgets, icons, boxes, taglist)
require 'keybindings'(boxes, widgets)
require 'rules'
require 'signals'
require 'autorun'
