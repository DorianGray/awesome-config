local base = require 'wibox.widget.base'
local color = require 'gears.color'
local beautiful = require 'beautiful'
local naughty = require 'naughty'
local lgi = require 'lgi'

local function recolor(icon, color)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, icon.width, icon.height)
  local cr = lgi.cairo.Context(surface)
  local pat = lgi.cairo.Pattern
  cr:set_source(color)
  cr:mask(pat.create_for_surface(icon), 0, 0)
  return surface
end

local function draw_speaker(surface)
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color(beautiful.fg_normal))
  local centerx, centery = surface.width / 2, surface.height / 2
  local x = 0
  local y = centery - (surface.height * 0.15)
  local width = surface.width * 0.15
  local height = surface.height * 0.3
  cr:rectangle(x, y, width, height)
  cr:move_to(x + width, y + (surface.height * 0.3))
  cr:line_to(surface.width * 0.4, surface.height * 0.9)
  cr:line_to(surface.width * 0.4, surface.height * 0.1)
  cr:line_to(x + width, y)
  cr:fill()
end

local function draw_volume(surface, volume)
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color(beautiful.fg_normal))
  local centerx, centery = surface.width / 2, surface.height / 2
  cr:set_line_width(2)
  local max_arcs = 3
  local arc_width = centerx / max_arcs
  for arc = 1, (max_arcs * (volume / 100)) do
    local arc_height = arc * ((surface.height * 0.6) / max_arcs)
    local startx = centerx + ((centerx / max_arcs) * (arc - 1))
    local starty = centery - arc_height / 2
    local firstx, firsty = startx + (arc_width / 2), starty + (arc_height / 3)
    local secondx, secondy = startx + (arc_width / 2), starty + (2 * arc_height / 3)
    local thirdx, thirdy = startx, starty + arc_height
    cr:move_to(startx, starty)
    cr:curve_to(firstx, firsty, secondx, secondy, thirdx, thirdy)
    cr:stroke()
  end
  cr:fill()
end

local function icon_generate(width, height, volume, muted)
  -- Sanity check on the percentage
  if volume > 100 then volume = 100 end
  if volume < 0 then volume = 0 end

  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  draw_speaker(surface)
  draw_volume(surface, volume)
  if muted then
    surface = recolor(surface, color(beautiful.fg_urgent))
  end
  return surface
end

return function(width, height)
  return function(volume, muted)
    return icon_generate(width, height, volume, muted)
  end
end
