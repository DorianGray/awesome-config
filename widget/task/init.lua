local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local lgi = require 'lgi'

local unpack = table.unpack or unpack

local static = {}
local task = {}
task.__index = task

function static.update_callback(self, c, index, objects)
  c:update_icon()
end

function static.create_callback(self, c, index, objects)
  local icon = self:get_children_by_id('clienticon')[1]
  if c.update_icon == nil then
    local surface = gears.surface.duplicate_surface(c.icon)
    local width, height = gears.surface.get_size(surface)
    local pattern = lgi.cairo.Pattern.create_for_surface(surface)
    local cr = lgi.cairo.Context(surface)
    cr:rectangle(0, 0, width, height)
    cr:set_source_rgb(0, 0, 0)
    cr:set_operator(lgi.cairo.Operator.HSL_SATURATION)
    cr:mask(pattern)

    local real_client = c
    local dummy_client = {icon=surface, valid=c.valid, icon_sizes = {{width, height}}, get_icon=function() return surface end}
    function c:update_icon()
      if self == client.focus then
        icon.client = real_client
      else
        icon.client = dummy_client
      end
    end
  end
  local tooltip = awful.tooltip({
    objects = {self},
    timer_function = function()
      return c.name
    end,
    align = "left",
    mode = "outside",
    preferred_positions = {"left"},
  })
end


local instance = nil
static.buttons = awful.util.table.join(unpack({
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then
        c:tags()[1]:view_only()
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
      instance = awful.menu.clients({width=250 * beautiful.scale})
    end
  end),
  awful.button({}, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({}, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end)
}))

function task:new()
  local self = setmetatable({}, task)
  self.widgets = {}
  return self 
end

function task:widget(s)
  local widget = self.widgets[s]
  if not widget then
    widget = awful.widget.tasklist({
      screen = s,
      filter = awful.widget.tasklist.filter.currenttags,
      buttons = static.buttons,
      layout  = wibox.layout.fixed.horizontal(),
      widget_template = {
        {
          id = 'clienticon',
          widget = awful.widget.clienticon,
        },
        create_callback = static.create_callback,

        update_callback = static.update_callback,
        layout = wibox.layout.align.vertical,
      },
    })
    self.widgets[s] = widget
  end
  return widget
end

return setmetatable(static, {__call=task.new})
