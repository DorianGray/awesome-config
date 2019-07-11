local awful = require 'awful'
local beautiful = require 'beautiful'
local naughty = require 'naughty'

local tags = require 'tags'

local systray = 32
-- Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {rule = { },
  properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    keys = clientkeys,
    buttons = clientbuttons,
    size_hints_honor = false
  }},

  {rule = {class = 'alacritty', class='google-chrome', class='Google-chrome'},
  properties = {
    y = systray,
    x = 0,
  }},

  {rule = {class = 'alacritty'},
  properties = {
    tag = tags[1][1],
    width = screen[1].workarea.width,
    height = screen[1].workarea.height,
  }},

  {rule = {class = 'google-chrome', class = 'Google-chrome'},
  callback = function(c)
    local s, t = 1, 2
    if screen.count() >= 2 then
      s, t = 2, 1
    end
    c:tags({tags[s][t]})

    c:geometry({
      width = screen[s].workarea.width,
      height = screen[s].workarea.height,
    })
  end},

  {rule = {class = 'discord', class = 'discord'},
  callback = function(c)
    local s, t = 1, 2
    if screen.count() >= 2 then
      s, t = 2, 1
    end
    c:tags({tags[s][t]})

    c:geometry({
      width = screen[s].workarea.width,
      height = screen[s].workarea.height,
    })
  end},

}
