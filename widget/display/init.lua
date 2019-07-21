local awful = require 'awful'
local icon = require 'widget.display.icon.display'(32, 32)
local beautiful = require 'beautiful'

local args = {
  image = icon(),
  menu = awful.menu({
    items = {},
    theme = {
      width = beautiful.menu_width,
      height = beautiful.menu_height,
    },
  }),
}

local widget = awful.widget.launcher(args)
widget.menu = args.menu
return widget
