local awful = require 'awful'
local tags = {
  names = {
    '1',
    '2',
  },
  layout = {
    awful.layout.suit.tile,
    awful.layout.suit.tile,
  }
}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layout)
end

return tags
