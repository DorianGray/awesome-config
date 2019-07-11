local os = require 'os'
local gears     = require 'gears'
local awful     = require 'awful'
awful.rules     = require 'awful.rules'
require 'awful.autofocus'
local wibox     = require 'wibox'
local beautiful = require 'beautiful'
local naughty   = require 'naughty'
local layouts   = require 'layouts'
local theme     = require 'theme'

-- Add local luarocks repo to package.path
package.path = os.getenv('HOME')..'/.luarocks/share/lua/5.1/?.lua;'..os.getenv('HOME')..'/.luarocks/share/lua/5.1/?/init.lua;'..package.path
package.cpath = os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?.so;'..os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?/init.so;'..package.cpath


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
widgets.clock = wibox.widget.textclock('%H:%M')
-- calendar
widgets.calendar = awful.widget.calendar_popup.month({
  font=theme.font_name..' '..theme.font_size,
  start_sunday=true,
})
widgets.calendar:attach(widgets.clock, "tr")

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
  width = 30 * theme.scale,
  height = 10 * theme.scale,
  bolt_width = 30 * theme.scale,
  bolt_height = 15 * theme.scale,
  stroke_width = 2 * theme.scale,
  peg_top = 4 * theme.scale,
  peg_height = 6 * theme.scale,
  peg_width = 4 * theme.scale,
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
