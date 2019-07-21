-- Add local luarocks repo to package.path
package.path = os.getenv('HOME')..'/.luarocks/share/lua/5.1/?.lua;'..os.getenv('HOME')..'/.luarocks/share/lua/5.1/?/init.lua;'..package.path
package.cpath = os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?.so;'..os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?/init.so;'..package.cpath

local os = require 'os'

require 'error_handler'

local config = require 'config'
local beautiful = require 'beautiful'
local gears = require 'gears'
local awful = require 'awful'
local wibox = require 'wibox'
local layouts = require 'layouts'

-- beautiful init
local theme = require('theme.' .. config.theme)
beautiful.init(theme)

local icons = {}
local boxes = {
  wi = {},
  prompt = {},
  layout = {},
}
local taglist = {}

local widgets = {}
-- Textclock
widgets.clock = wibox.widget.textclock('%H:%M')
-- calendar
widgets.calendar = awful.widget.calendar_popup.month({
  font=beautiful.font,
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
  width = 30 * beautiful.scale,
  height = 10 * beautiful.scale,
  bolt_width = 30 * beautiful.scale,
  bolt_height = 15 * beautiful.scale,
  stroke_width = 2 * beautiful.scale,
  peg_top = 4 * beautiful.scale,
  peg_height = 6 * beautiful.scale,
  peg_width = 4 * beautiful.scale,
  font = beautiful.font,
  critical_level = 0.10,
  normal_color = beautiful.fg_normal,
  critical_color = beautiful.fg_urgent,
  charging_color = beautiful.fg_normal,
})

-- Audio
widgets.volume = require 'widget.volume'

-- Net
widgets.network = require 'widget.net'(boxes.prompt).widget

-- Power
widgets.power = require 'widget.power'

-- Display
widgets.display = require 'widget.display'

require 'layout'(widgets, icons, boxes, taglist)
require 'keybindings'(boxes, widgets)
awful.rules.rules = require 'rules'
require 'awful.autofocus'
require 'signals'
require 'autorun'()
