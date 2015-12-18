local awful = require 'awful'
local beautiful = require 'beautiful'
local naughty = require 'naughty'

local tags = require 'tags'

-- Rules
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
  properties = { border_width = beautiful.border_width,
  border_color = beautiful.border_normal,
  focus = awful.client.focus.filter,
  keys = clientkeys,
  buttons = clientbuttons,
  size_hints_honor = false } },

  { rule = { instance = 'plugin-container' },
  properties = { tag = tags[1][1] } },

  { rule = { class = 'urxvt' },
  properties = {
    tag = tags[1][1],
    y = 16,
    x = 0,
    width = screen[1].workarea.width,
    height = screen[1].workarea.height,
  }
},

{
  rule = { class = 'google-chrome' },
  callback = function(c)
    if screen.count() >= 2 then
      c:tags({tags[2][1]})
    else
      c:tags({tags[1][2]})
    end
    c:geometry({
      y = 16,
      x = 0,
      width = screen[1].workarea.width,
      height = screen[1].workarea.height,
    })
  end,
},

{ rule = { class = 'Gimp', role = 'gimp-image-window' },
properties = { maximized_horizontal = true,
maximized_vertical = true } },
}
