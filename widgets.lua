local wibox = require 'wibox'
local awful = require 'awful'

local mt = {}
mt.__index = mt

function mt:__call(theme, build)
  local o = setmetatable({}, mt)
  if build then
    o:build(theme)
  end
  return o
end

function mt:build(theme)
  local widgets = {}
  self.widgets = widgets

  -- Layout control
  widgets.layout = require 'widget.layout'
  -- Tag Control
  widgets.tags = require 'widget.tag'()
  -- Textclock
  widgets.clock = wibox.widget.textclock('%H:%M')
  -- calendar
  widgets.calendar = awful.widget.calendar_popup.month({
    font=theme.font,
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
    font = theme.font,
    critical_level = 0.10,
    normal_color = theme.fg_normal,
    critical_color = theme.fg_urgent,
    charging_color = theme.fg_normal,
  })

  -- Audio
  widgets.volume = require 'widget.volume'

  -- Net
  widgets.network = require 'widget.net'().widget

  -- Power
  widgets.power = require 'widget.power'

  -- Display
  widgets.display = require 'widget.display'
end

return setmetatable({}, mt)
