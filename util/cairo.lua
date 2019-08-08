local gears = require 'gears'
local lgi = require 'lgi'

local cairo = {}

function cairo.grayscale(surface)
  local width, height = gears.surface.get_size(surface)
  local pattern = lgi.cairo.Pattern.create_for_surface(surface)
  local cr = lgi.cairo.Context(surface)
  cr:rectangle(0, 0, width, height)
  cr:set_source_rgb(0, 0, 0)
  cr:set_operator(lgi.cairo.Operator.HSL_SATURATION)
  cr:mask(pattern)
end

function cairo.darken(surface, percent)
  local cr = lgi.cairo.Context(surface)
  cr:set_source_rgba(0, 0, 0, percent)
  cr:set_operator(lgi.cairo.Operator.ATOP)
  cr:paint()
end

return cairo
