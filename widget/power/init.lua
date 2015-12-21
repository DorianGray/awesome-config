local awful = require 'awful'
local icon = require 'widget.power.icon.power'(32, 32)
local args = {
  image = icon(),
  menu = awful.menu({
    items = {
      {'Lock', 'gnome-screensaver-command -l'},
      {'Shutdown', 'gksudo poweroff'},
      {'Restart', 'gksudo reboot'},
    },
    theme = {
      width = 75,
      height = 16,
    },
  }),
}

local widget = awful.widget.launcher(args)
widget.menu = args.menu
return widget
