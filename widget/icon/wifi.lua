local base = require 'wibox.widget.base'
local color = require 'gears.color'
local beautiful = require 'beautiful'
local naughty = require 'naughty'
local lgi = require 'lgi'

local function icon_generate(width, height, signal)
  -- Sanity check on the percentage
  if signal > 100 then signal = 100 end
  if signal < 0 then signal = 0 end

  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  local cr = lgi.cairo.Context(surface)

  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  local signal_filled = 0
  while signal_filled < signal do
    signal_filled = signal_filled + 20
    local x = ((signal_filled / 100) * width)+1
    local y = ((0.9*height) * ((100-signal_filled) / 100)) - (height * 0.1)
    local x2 = (width-5) / 5
    local y2 = height-(y+height*0.2)
    cr:rectangle(x, y, x2, y2)
  end
  cr:set_source(color(beautiful.fg_normal))
  cr:fill()
  return surface
end

return function(width, height)
  return {
    icon_generate(width, height, 0),
    icon_generate(width, height, 25),
    icon_generate(width, height, 50),
    icon_generate(width, height, 75),
    icon_generate(width, height, 100),
  }
end
