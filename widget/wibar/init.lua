local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local keys = require 'keybindings'


local static = {}
static.__index = static
local wibar = {}
wibar.__index = wibar

function wibar:new()
  local self = setmetatable({}, wibar)
  self.widgets = {}
  self.keys = {
    -- Show/Hide Wibox
    awful.key({keys.MOD}, 'b', function ()
      local wibar = self:widget(mouse.screen)
      wibar.visible = not wibar.visible
    end),
    --Prompt
    awful.key({keys.MOD}, 'r', function ()
      local wibar = self:widget(mouse.screen)
      wibar.prompt:run()
    end),
    awful.key({keys.MOD}, 'x',
    function ()
      local wibar = self:widget(mouse.screen)
      awful.prompt.run({
        prompt = 'Run lua: ',
        textbox = self.prompt.widget,
        exe_callback = awful.util.eval,
        history_path = gears.filesystem.get_dir('cache') .. '/history_eval',
      })
    end),
  }
  return self
end

function wibar:widget(s)
  local widget = self.widgets[s]
  if not widget then
    widget = awful.wibar({
      position = 'top',
      screen = s,
      height = beautiful.wibar.height,
    })

    -- multipurpose prompt box
    widget.prompt = awful.widget.prompt()

    -- Widgets that are aligned to the upper left
    widget.layout = {
      left = wibox.layout.fixed.horizontal(),
      middle = wibox.layout.fixed.horizontal(),
      right = wibox.layout.fixed.horizontal(),
    }

    local layout = wibox.layout.align.horizontal()
    layout:set_left(widget.layout.left)
    layout:set_right(widget.layout.right)
    layout:set_middle(widget.layout.middle)
    widget:set_widget(layout)

    -- Widgets that are aligned to the upper right
    local right_toggle = true
    local right_add = widget.layout.right.add
    
    function widget.layout.right:add(...)
      local arg = {...}
      if right_toggle then
        local layout = wibox.layout.fixed.horizontal()
        local margin = wibox.container.margin(layout)
        margin.right = beautiful.wibar.height / 8
        margin.left = beautiful.wibar.height / 8
        local container = wibox.container.background(margin)
        container.shape = function(cr, width, height)
          return gears.shape.powerline(cr, width, height, -(height / 8))
        end
        container.fg = 'alpha'
        container.bg = beautiful.bg_focus
        for _, n in pairs(arg) do
          layout:add(wibox.container.background(n, beautiful.bg_focus))
        end
        right_add(self, container)
      else
        for _, n in pairs(arg) do
          right_add(self, n)
        end
      end
      right_toggle = not right_toggle
    end
    widget.layout.middle:add(widget.prompt)
    self.widgets[s] = widget
  end

  return widget
end

return setmetatable(static, {__call=wibar.new})
