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

local widgets = {}
local icons = {}
local boxes = {
  wi = {},
  prompt = {},
  layout = {},
}
local taglist = {}

-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- Wibox
local separators = lain.util.separators

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

-- Separators
local spr = wibox.widget.textbox(' ')
local arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
local arrl_dl = separators.arrow_left(beautiful.bg_focus, 'alpha')
local arrl_ld = separators.arrow_left('alpha', beautiful.bg_focus)

-- Create a wibox for each screen and add it
taglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ 'Mod4' }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ 'Mod4' }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

local tasklists = {}
tasklists.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
  if c == client.focus then
    c.minimized = true
  else
    -- Without this, the following
    -- :isvisible() makes no sense
    c.minimized = false
    if not c:isvisible() then
      awful.tag.viewonly(c:tags()[1])
    end
    -- This will also un-minimize
    -- the client, if needed
    client.focus = c
    c:raise()
  end
end),
awful.button({ }, 3, function ()
  if instance then
    instance:hide()
    instance = nil
  else
    instance = awful.menu.clients({ width=250 })
  end
end),
awful.button({ }, 4, function ()
  awful.client.focus.byidx(1)
  if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do

  -- Create a promptbox for each screen
  boxes.prompt[s] = awful.widget.prompt()

  -- We need one layoutbox per screen.
  boxes.layout[s] = awful.widget.layoutbox(s)
  boxes.layout[s]:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

  -- Create a taglist widget
  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

  -- Create a tasklist widget
  tasklists[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklists.buttons)

  -- Create the wibox
  boxes.wi[s] = awful.wibox({ position = 'top', screen = s, height = 18 })

  -- Widgets that are aligned to the upper left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(boxes.layout[s])
  left_layout:add(spr)
  left_layout:add(taglist[s])
  left_layout:add(boxes.prompt[s])
  left_layout:add(spr)


  -- Widgets that are aligned to the upper right
  local right_layout = wibox.layout.fixed.horizontal()
  local right_layout_toggle = true
  local function right_layout_add (...)
    local arg = {...}
    if right_layout_toggle then
      right_layout:add(arrl_ld)
      for i, n in pairs(arg) do
        right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))
      end
    else
      right_layout:add(arrl_dl)
      for i, n in pairs(arg) do
        right_layout:add(n)
      end
    end
    right_layout_toggle = not right_layout_toggle
  end

  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(spr)
  right_layout:add(arrl)
  right_layout_add(icons.volume, widgets.volume)
  right_layout_add(icons.memory, widgets.memory, icons.cpu, widgets.cpu)
  right_layout_add(icons.battery, widgets.battery)
  right_layout_add(widgets.network)
  right_layout_add(widgets.clock, spr)

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(tasklists[s])
  layout:set_right(right_layout)
  boxes.wi[s]:set_widget(layout)
end

require 'keybindings'(boxes, widgets)
require 'rules'
require 'signals'
require 'autorun'
