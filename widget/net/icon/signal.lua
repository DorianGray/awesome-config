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

local function draw_signal(surface, signal, connected, color)
  if not connected then
    signal = 100
  end
  local cr = lgi.cairo.Context(surface)
  cr:set_fill_rule(lgi.cairo.FillRule.EVEN_ODD)
  cr:set_source(color)
  local centerx = surface.width / 2
  cr:set_line_width(2)
  local percent = signal / 100
  local arc_height = (surface.height * 0.3) * percent
  local height = (surface.height) - arc_height
  local arc_y = surface.height - (height * percent)
  local arc_start = {
    x = centerx - (surface.width / 2) * percent,
    y = arc_y,
  }
  local arc_end = {
    x = centerx + (surface.width / 2) * percent,
    y = arc_y,
  }
  local arc_width = arc_end.x - arc_start.x
  cr:move_to(centerx, surface.height * 0.9)
  cr:line_to(arc_start.x, arc_start.y)
  cr:curve_to(
  arc_start.x + (arc_width / 3), arc_start.y - arc_height,
  arc_start.x + (2 * (arc_width / 3)), arc_start.y - arc_height,
  arc_end.x, arc_end.y
  )
  cr:line_to(centerx, surface.height * 0.9)
  if not connected then
    cr:stroke()
  else
    cr:fill()
  end
end

local function icon_generate(width, height, signal, connected, internet)
  -- Sanity check on the percentage
  if signal > 100 then signal = 100 end
  if signal < 0 then signal = 0 end

  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  draw_signal(surface, 100, true, color('#44444499'))
  draw_signal(surface, signal, connected, color(beautiful.fg_normal), 1)
  if not connected or not internet then
    surface = recolor(surface, color(beautiful.fg_urgent))
  end
  return surface
end

return function(width, height)
  return function(signal, connected, internet)
--[[    signal = 50
    connected = true
    internet = true]]
    return icon_generate(width, height, signal, connected, internet)
  end
end
