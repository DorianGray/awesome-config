local awful = require 'awful'
local awesome = require 'awesome'
local gears = require 'gears'
local util = require 'util'
local screen = require 'screen'
local client = require 'client'
local keys = require 'keybindings'


local buttons = awful.util.table.join(
  awful.button({}, 1, function(tag) tag:view_only() end),
  awful.button({'Mod4'}, 1, function(tag) client.focus:move_to_tag(tag) end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({'Mod4'}, 3, awful.client.toggletag),
  awful.button({}, 4, function(tag) awful.tag.viewnext(tag.screen) end),
  awful.button({}, 5, function(tag) awful.tag.viewprev(tag.screen) end)
)

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
  return awful.widget.taglist(s, awful.widget.taglist.filter.all, buttons)
end

mt.keys = {
  awful.key({keys.MOD}, 'Left', awful.tag.viewprev),
  awful.key({keys.MOD}, 'Right', awful.tag.viewnext),
  awful.key({keys.MOD}, 'Escape', awful.tag.history.restore),
}

return setmetatable({}, mt)
