local awful = require 'awful'
local keys = require 'keybindings'

local mt = {}
mt.__index = mt

local layouts =  {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
}


-- We need one layoutbox per screen.
function mt:__call(s, tags)
 local layout = awful.widget.layoutbox(s)
  layout:buttons(awful.util.table.join(
  awful.button({}, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({}, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({}, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({}, 5, function () awful.layout.inc(layouts, -1) end)))
  return layout
end

mt.keys = {
  awful.key({keys.MOD,}, 'space',  function () awful.layout.inc(layouts, 1) end),
  awful.key({keys.MOD, 'Shift'}, 'space', function () awful.layout.inc(layouts, -1) end),
}

return setmetatable({}, mt)
