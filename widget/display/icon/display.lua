local base = require 'wibox.widget.base'
local color = require 'gears.color'
local beautiful = require 'beautiful'
local naughty = require 'naughty'
local lgi = require 'lgi'

local function draw_display(surface)
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color(beautiful.fg_normal))
  local centerx, centery = surface.width / 2, surface.height / 2
  cr:set_line_width(math.min(surface.height, surface.width) * 0.1)
  local rect_width = surface.width * 0.7
  local rect_height = surface.height * 0.5
  cr:rectangle(centerx - (rect_width / 2), centery - (rect_height / 2), rect_width,  rect_height)
  cr:stroke()
  cr:fill()
end

local function icon_generate(width, height)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  draw_display(surface)
  return surface
end

return function(width, height)
  return function()
    return icon_generate(width, height)
  end
end
