local awful = require 'awful'
local awesome = require 'awesome'
local gears = require 'gears'
local util = require 'util'
local screen = require 'screen'


-- Create a wibox for each screen and add it
local buttons = awful.util.table.join(
  awful.button({ }, 1, function(tag) tag:view_only() end),
  awful.button({ 'Mod4' }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ 'Mod4' }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(tag) awful.tag.viewnext(tag.screen) end),
  awful.button({ }, 5, function(tag) awful.tag.viewprev(tag.screen) end)
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

local modkey = 'Mod4'
local altkey = 'Mod1'
mt.keys = {
  awful.key({ modkey }, 'Left', awful.tag.viewprev       ),
  awful.key({ modkey }, 'Right', awful.tag.viewnext       ),
  awful.key({ modkey }, 'Escape', awful.tag.history.restore),
  awful.key({ altkey, 'Shift'   }, 'l', function () awful.tag.incmwfact( 0.05) end),
  awful.key({ altkey, 'Shift'   }, 'h', function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, 'Shift'   }, 'l', function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, 'Shift'   }, 'h', function () awful.tag.incnmaster( 1) end),
  awful.key({ modkey, 'Control' }, 'l', function () awful.tag.incncol(-1) end),
  awful.key({ modkey, 'Control' }, 'h', function () awful.tag.incncol( 1) end),
}

return setmetatable({}, mt)
