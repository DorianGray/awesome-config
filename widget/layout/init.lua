local awful = require 'awful'

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
  awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  return layout
end

local modkey='Mod4'
mt.keys = {
  awful.key({ modkey,           }, 'space',  function () awful.layout.inc(layouts,  1)  end),
  awful.key({ modkey, 'Shift'   }, 'space',  function () awful.layout.inc(layouts, -1)  end),
}

return setmetatable({}, mt)
