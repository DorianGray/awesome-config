local awful = require 'awful'
local theme = require 'theme'
local icon = require 'widget.power.icon.power'(
  32 * theme.scale,
  32 * theme.scale
)
local beautiful = require 'beautiful'
local theme = require 'theme'

local args = {
  image = icon(),
  menu = awful.menu({
    items = {
      {'Lock', theme.lock_command},
      {'Log Off', theme.logout_command},
      {'Shutdown', theme.shutdown_command},
      {'Restart', theme.reboot_command},
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
