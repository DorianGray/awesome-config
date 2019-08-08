local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'util'
local lgi = require 'lgi'

local unpack = table.unpack or unpack

local static = {}
local task = {}
task.__index = task

local cache_mt = {
  __mode='k',
}

function static.update_callback(self, c, index, objects)
  self:update_icon()
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
  self.unfocused_cache = setmetatable({}, cache_mt)
  return self 
end

function task:widget(s)
  local widget = self.widgets[s]
  if not widget then 
    local function create_callback(self, c, index, objects)
      -- self is the container widget for each client in the tasklist, so we
      -- need to look at the children to find the icon container by id
      local icon_widget = self:get_children_by_id('clienticon')[1]
      -- fake client that returns the grayscale versions of icons
      local unfocused_client = {
        valid=c.valid,
        icon_sizes = c.icon_sizes,
        get_icon=function(self, index)
          local icon = c:get_icon(index)
          local unfocused_cache = widget.unfocused_cache[c]
          if not unfocused_cache then
            unfocused_cache = setmetatable({}, cache_mt)
            widget.unfocused_cache[c] = unfocused_cache
          end
          local unfocused_icon = unfocused_cache[icon]
          if not unfocused_icon then
            unfocused_icon = gears.surface.duplicate_surface(icon)
            util.cairo.grayscale(unfocused_icon)
            util.cairo.darken(unfocused_icon, 0.25)
            unfocused_cache[icon] = unfocused_icon
            self.icon_sizes = c.icon_sizes
            self.valid = c.valid
          end
          return unfocused_icon
        end,
      }

      function self:update_icon()
        if c == client.focus then
          icon_widget.client = c
        else
          icon_widget.client = unfocused_client
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
        create_callback = create_callback,
        update_callback = static.update_callback,
        layout = wibox.layout.align.vertical,
      },
    })
    widget.unfocused_cache = self.unfocused_cache
    self.widgets[s] = widget
  end
  return widget
end

return setmetatable(static, {__call=task.new})
