local base = require 'wibox.widget.base'
local color = require 'gears.color'
local beautiful = require 'beautiful'
local naughty = require 'naughty'
local lgi = require 'lgi'

local function draw_power(surface)
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color(beautiful.fg_normal))
  local centerx, centery = surface.width / 2, surface.height / 2
  local radius = (surface.width / 2) * 0.6
  cr:set_line_width(math.min(surface.height, surface.width) * 0.1)
  cr:arc_negative(centerx, centery, radius, math.rad(230), math.rad(310))
  cr:stroke()
  local rect_width = surface.width * 0.1
  local rect_height = (surface.height*0.7) / 2
  cr:rectangle(centerx - (rect_width / 2), centery - rect_height, rect_width, centery * 0.8)
  cr:fill()
end

local function icon_generate(width, height)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  draw_power(surface)
  return surface
end

return function(width, height)
  return function()
    return icon_generate(width, height)
  end
end
