local awful = require 'awful'
local awesome = require 'awesome'
local tags = {
  names = {},
  layout = {},
}

num_tags = screen.count() > 1 and 1 or 2

for t = 1, num_tags do
  table.insert(tags.names, tostring(t))
  table.insert(tags.layout, awful.layout.suit.tile)
end

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layout)
  tags[s][1]:connect_signal("request::screen", awesome.restart)
end

return tags
