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
  local to_signal = signal > 0 and signal or 100
  local signal_filled = 0
  while signal_filled < to_signal do
    signal_filled = signal_filled + 20
    local x = ((signal_filled / 100) * width)+1
    local y = ((0.9*height) * ((100-signal_filled) / 100)) - (height * 0.1)
    local x2 = (width-5) / 5
    local y2 = height-(y+height*0.2)
    cr:rectangle(x, y, x2, y2)
  end
  cr:set_source(color(beautiful.fg_normal))
  cr:fill()
  if signal == 0 then
    cr:set_operator(lgi.cairo.Operator.CLEAR)
    signal_filled = 0
    while signal_filled < to_signal do
      signal_filled = signal_filled + 20
      local x = ((signal_filled / 100) * width)+2
      local y = (((0.9*height) * ((100-signal_filled) / 100)) - (height * 0.1))+1
      local x2 = ((width-5) / 5) - 2
      local y2 = height-(y+height*0.2) - 1
      cr:rectangle(x, y, x2, y2)
    end
    cr:fill()
  end
  return surface
end

local function recolor(icon, color)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, icon.width, icon.height)
  local cr = lgi.cairo.Context(surface)
  local pat = lgi.cairo.Pattern
  cr:set_source(color)
  cr:mask(pat.create_for_surface(icon), 0, 0)
  return surface
end

return function(width, height)
  local icons = {
    normal = {
      icon_generate(width, height, 0),
      icon_generate(width, height, 25),
      icon_generate(width, height, 50),
      icon_generate(width, height, 75),
      icon_generate(width, height, 100),
    },
    nowan = {}
  }
  for _, v in pairs(icons.normal) do
    icons.nowan[#icons.nowan+1] = recolor(v, color(beautiful.fg_urgent))
  end

  icons.disconnected = icons.nowan[1]

  function icons.from_signal(signal, nowan)
    if type(signal) ~= 'number' then return icons.disconnected end
    if signal == 0 then return icons.disconnected end
    local index = math.ceil(signal / 20)
    if nowan then
      return icons.nowan[index]
    end
    return icons.normal[index]
  end

  return icons
end
