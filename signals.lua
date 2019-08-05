local beautiful = require 'beautiful'
local awful = require 'awful'
local client = require 'client'
local screen = require 'screen'

require 'awful.autofocus'


-- Signals
-- signal function to execute when a new client appears.
local sloppyfocus_last = nil
client.connect_signal('manage', function (c, startup)
  -- Enable sloppy focus
  client.connect_signal('mouse::enter', function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      -- Skip focusing the client if the mouse wasn't moved.
      if c ~= sloppyfocus_last then
        client.focus = c
        sloppyfocus_last = c
      end
    end
  end)
end)

-- No border for maximized clients
client.connect_signal('focus', function(c)
  if c.maximized_horizontal == true and c.maximized_vertical == true then
    c.border_color = beautiful.border_normal
  else
    c.border_color = beautiful.border_focus
  end
end)

client.connect_signal('unfocus', function(c)
  c.border_color = beautiful.border_normal
end)

-- Arrange signal handler
for s in screen do s:connect_signal('arrange', function ()
    local clients = awful.client.visible(s)
    local layout  = awful.layout.getname(awful.layout.get(s))

    if #clients > 0 then -- Fine grained borders and floaters control
      for _, c in pairs(clients) do -- Floaters always have borders
        if c.floating or layout == 'floating' then
          c.border_width = beautiful.border_width

          -- No borders with only one visible client
        elseif #clients == 1 or layout == 'max' then
          c.border_width = 0
        else
          c.border_width = beautiful.border_width
        end
      end
    end
  end)
end
