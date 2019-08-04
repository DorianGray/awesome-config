local color = require 'gears.color'
local beautiful = require 'beautiful'
local lgi = require 'lgi'


local function icon(width, height)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color('#DDDDFF'))
  local centerx, centery = surface.width / 2, surface.height / 2
  cr:set_line_width(math.min(surface.height, surface.width) * 0.05)
  local rect_width = surface.width * 0.25
  local rect_height = surface.height * 0.75
  cr:rectangle(centerx / 3 - (rect_width / 2), centery - rect_height / 2, rect_width,  rect_height)
  cr:rectangle(centerx - centerx * 0.1, centery / 4, rect_width * 2,  rect_height / 4)
  cr:rectangle(centerx - centerx * 0.1, centery / 1.25, rect_width * 2,  rect_height / 4)
  cr:rectangle(centerx - centerx * 0.1, centery * 1.35, rect_width * 2,  rect_height / 4)
  cr:stroke()
  cr:fill()
  return surface
end

return function(width, height)
  return function()
    return icon(width, height)
  end
end
