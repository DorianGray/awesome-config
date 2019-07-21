local awful = require 'awful'
local beautiful = require 'beautiful'

-- Rules
return {
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
}
