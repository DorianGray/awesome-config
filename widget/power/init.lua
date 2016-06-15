local awful = require 'awful'
local icon = require 'widget.power.icon.power'(32, 32)
local beautiful = require 'beautiful'
local args = {
  image = icon(),
  menu = awful.menu({
    items = {
      {'Lock', 'gnome-screensaver-command -l'},
      {'Shutdown', 'poweroff'},
      {'Restart', 'reboot'},
    },
    theme = {
      width = beautiful.menu_width,
      height = beautiful.menu_height,
    },
  }),
}

local widget = awful.widget.launcher(args)
widget.menu = args.menu
return widget
