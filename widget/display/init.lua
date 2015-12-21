local awful = require 'awful'
local icon = require 'widget.display.icon.display'(32, 32)
local args = {
  image = icon(),
  menu = awful.menu({
    items = {},
    theme = {
      width = 75,
      height = 16,
    },
  }),
}

local widget = awful.widget.launcher(args)
widget.menu = args.menu
return widget
