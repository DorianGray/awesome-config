local gears     = require 'gears'
local awful     = require 'awful'
awful.rules     = require 'awful.rules'
require 'awful.autofocus'
local wibox     = require 'wibox'
local beautiful = require 'beautiful'
local naughty   = require 'naughty'
local lain      = require 'lain'
local layouts   = require 'layouts'

-- Error handling
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = awesome.startup_errors,
  })
end

do
  local in_error = false
  awesome.connect_signal('debug::error', function (err)
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = 'Oops, an error happened!',
      text = err,
    })
    in_error = false
  end)
end

-- beautiful init
beautiful.init(os.getenv('HOME') .. '/.config/awesome/themes/powerarrow-darker/theme.lua')

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
icons.clock = wibox.widget.imagebox(beautiful.widget_clock)
widgets.clock = lain.widgets.abase({
  timeout  = 60,
  cmd      = 'date +\'%a %d %b %R\'',
  settings = function()
    widget:set_text(' ' .. output)
  end
})

-- calendar
widgets.calendar = lain.widgets.calendar
widgets.calendar:attach(widgets.clock, { font_size = 10 })

-- MEM
icons.memory = wibox.widget.imagebox(beautiful.widget_mem)
widgets.memory = lain.widgets.mem({
  settings = function()
    widget:set_text(' ' .. mem_now.used .. 'MB ')
  end
})

-- CPU
icons.cpu = wibox.widget.imagebox(beautiful.widget_cpu)
widgets.cpu = lain.widgets.cpu({
  settings = function()
    widget:set_text(' ' .. cpu_now.usage .. '% ')
  end
})

-- Battery
icons.battery = wibox.widget.imagebox(beautiful.widget_battery)
widgets.battery = lain.widgets.bat({
  settings = function()
    if bat_now.perc == 'N/A' then
      widget:set_markup(' AC ')
      icons.battery:set_image(beautiful.widget_ac)
      return
    elseif tonumber(bat_now.perc) <= 5 then
      icons.battery:set_image(beautiful.widget_battery_empty)
    elseif tonumber(bat_now.perc) <= 15 then
      icons.battery:set_image(beautiful.widget_battery_low)
    else
      icons.battery:set_image(beautiful.widget_battery)
    end
    widget:set_markup(' ' .. bat_now.perc .. '% ')
  end
})

-- Audio
local volwidget = require 'widget.volume'
icons.volume = volwidget.icon 
widgets.volume = volwidget.widget

-- Net
widgets.network = require 'widget.net'.widget(boxes.prompt)

require 'layout'(widgets, icons, boxes, taglist)
require 'keybindings'(boxes, widgets)
require 'rules'
require 'signals'
require 'autorun'
