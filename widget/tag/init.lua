local awful = require 'awful'
local awesome = require 'awesome'
local gears = require 'gears'
local util = require 'util'
local screen = require 'screen'
local client = require 'client'
local keys = require 'keybindings'
local beautiful = require 'beautiful'


local buttons = awful.util.table.join(unpack({
  awful.button({}, 1, function(tag) tag:view_only() end),
  awful.button({'Mod4'}, 1, function(tag) client.focus:move_to_tag(tag) end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({'Mod4'}, 3, awful.client.toggletag),
  awful.button({}, 4, function(tag) awful.tag.viewnext(tag.screen) end),
  awful.button({}, 5, function(tag) awful.tag.viewprev(tag.screen) end)
}))

local mt = {}
mt.__index = mt

function mt:__call()
  local self = setmetatable({}, mt)
  self.tags = {}

  local num_tags = 2
  if screen.count() >= num_tags then
    num_tags = 1
  end

  for s in screen do
    self.tags[s] = {}
    for i=1, num_tags do
      table.insert(self.tags[s], awful.tag.add(i, {
        screen = s,
        layout = awful.layout.suit.tile,
      }))
    end
    -- set first tag on each screen to active
    self.tags[s][1]:view_only()
  end
  return self
end

function mt:screen(s)
  if type(s) == 'number' then
    s = screen[s]
  end
  return self.tags[s]
end

function mt:widget(s)
  local wibox = require 'wibox'
  return awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = buttons,
    style   = {
      shape = function(cr, width, height) return gears.shape.powerline(cr, width, height, height / 8) end,
    },
    widget_template = {
      {
        {
          id     = 'index_role',
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
      },
      id     = 'background_role',
      widget = wibox.container.background,
      -- Add support for hover colors and an index label
      create_callback = function(self, c3, index, objects)
        self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
        self:connect_signal('mouse::enter', function()
          if self.fg ~= beautiful.fg_urgent then
            self.backup     = self.fg
            self.has_backup = true
          end
          self.fg = beautiful.fg_urgent
        end)
        self:connect_signal('mouse::leave', function()
          if self.has_backup then self.fg = self.backup end
        end)
      end,
      update_callback = function(self, c3, index, objects)
        self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
      end,
    },
  })
end

mt.keys = {
  awful.key({keys.MOD}, 'Left', awful.tag.viewprev),
  awful.key({keys.MOD}, 'Right', awful.tag.viewnext),
  awful.key({keys.MOD}, 'Escape', awful.tag.history.restore),
  awful.key({keys.ALT, keys.SHIFT}, 'l', function () awful.tag.incmwfact(0.05) end),
  awful.key({keys.ALT, keys.SHIFT}, 'h', function () awful.tag.incmwfact(-0.05) end),
  awful.key({keys.MOD, keys.SHIFT}, 'l', function () awful.tag.incnmaster(-1) end),
  awful.key({keys.MOD, keys.SHIFT}, 'h', function () awful.tag.incnmaster(1) end),
  awful.key({keys.MOD, keys.CONTROL}, 'l', function () awful.tag.incncol(-1) end),
  awful.key({keys.MOD, keys.CONTROL}, 'h', function () awful.tag.incncol(1) end),
}

return setmetatable({}, mt)
