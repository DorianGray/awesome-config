local awful = require 'awful'
local beautiful = require 'beautiful'
local icon = require 'widget.power.icon.power'(
  32 * beautiful.scale,
  32 * beautiful.scale
)
local beautiful = require 'beautiful'

local args = {
  image = icon(),
  menu = awful.menu({
    items = {
      {'Lock', beautiful.command.lock},
      {'Log Off', beautiful.command.logout},
      {'Shutdown', beautiful.command.shutdown},
      {'Restart', beautiful.command.reboot},
    },
    theme = {
      width = beautiful.menu_width,
      height = beautiful.menu_height,
    },
  }),
}

local widget = awful.widget.launcher(args)
widget.menu = args.menu
widget.keys = {
  awful.key({ }, "XF86PowerOff", function() args.menu:toggle({coords={x=(mouse.screen.geometry.width - 75),y=0}}) end),
}
return widget
