local base = require 'wibox.widget.base'
local awful = require 'awful'
local color = require 'gears.color'
local beautiful = require 'beautiful'
local lgi = require 'lgi'
local gears = require 'gears'
local util = require 'util'

local o = { mt = {} }

local data = setmetatable({}, { __mode = 'k' })

local properties = { 'width', 'height' }

function o.fit(o, width, height)
  local width = 2 + data[o].width + (data[o].stroke_width * 2) + data[o].peg_width
  local height = 2 + data[o].height + (data[o].stroke_width * 2)
  return width, height
end

local function round(num, idp)
  return tonumber(string.format('%.' .. (idp or 0) .. 'f', num))
end

local function acpi_is_on_ac_power(battery)
  local o = util.read_file('/sys/class/power_supply/' .. battery .. '/status')
  return not string.match(o, 'Discharging')
end

local function acpi_battery_is_present(battery)
  local o = util.read_file('/sys/class/power_supply/' .. battery .. '/present')
  return string.find(o, '1')
end

local function acpi_battery_is_charging(battery)
  local o = util.read_file('/sys/class/power_supply/' .. battery .. '/status')
  return string.find(o, 'Charging')
end

local function acpi_battery_percent(battery)
  local now  = util.read_file('/sys/class/power_supply/' .. battery .. '/energy_now') or
         util.read_file('/sys/class/power_supply/' .. battery .. '/charge_now')
  local full = util.read_file('/sys/class/power_supply/' .. battery .. '/energy_full') or
         util.read_file('/sys/class/power_supply/' .. battery .. '/charge_full')
  if (now == nil) or (full == nil) then return 0 end
  return tonumber(now)/tonumber(full)
end

local function acpi_battery_runtime(battery)
  local output = util.run('acpi')
  if not output then
    return 'No Battery Found'
  end
  local _, _, state, percent, time = output:find('Battery %d+: (%a*), (%d*)%%,? ?(%S*)')
  return 'State: '..state..'\r\nCapacity: '..percent..'%'..(time ~= '' and '\r\nRemaining: '..time or '')
end

local function battery_bolt_generate(width, height)
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  local cr = lgi.cairo.Context(surface)

  cr:new_path()

  cr:move_to(width * ( 0.0/19), height * ( 3.0/11))
  cr:line_to(width * (11.0/19), height * (11.0/11))
  cr:line_to(width * (11.0/19), height * ( 5.5/11))
  cr:line_to(width * (19.0/19), height * ( 8.0/11))
  cr:line_to(width * ( 8.0/19), height * ( 0.0/11))
  cr:line_to(width * ( 8.0/19), height * ( 5.5/11))

  cr:close_path()

  return cr:copy_path()
end

local function battery_border_generate(args)
  local args = args or {}
  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, args.width, args.height)
  local cr = lgi.cairo.Context(surface)

  local outside_width  = args.width  + (args.stroke_width * 2)
  local outside_height = args.height + (args.stroke_width * 2)

  cr:new_path()

  cr:move_to(0                             , 0                             )
  cr:line_to(outside_width                 , 0                             )
  cr:line_to(outside_width                 , args.peg_top                  )
  cr:line_to(outside_width + args.peg_width, args.peg_top                  )
  cr:line_to(outside_width + args.peg_width, args.peg_top + args.peg_height)
  cr:line_to(outside_width                 , args.peg_top + args.peg_height)
  cr:line_to(outside_width                 , outside_height                )
  cr:line_to(0                             , outside_height                )

  cr:rectangle(args.stroke_width, args.stroke_width, args.width, args.height);

  cr:close_path()

  return cr:copy_path()
end

local function battery_fill_generate(width, height, percent)
  -- Sanity check on the percentage
  local percent = percent
  if percent > 1 then percent = 1 end
  if percent < 0 then percent = 0 end

  local surface = lgi.cairo.ImageSurface(lgi.cairo.Format.ARGB32, width, height)
  local cr = lgi.cairo.Context(surface)
  cr:new_path()
  cr:rectangle(0, 0, round(width * percent), height)
  cr:close_path()
  return cr:copy_path()
end

local properties = {
  'battery', 'width', 'height', 'peg_top',
  'peg_height', 'peg_width', 'stroke_width',
  'font', 'critical_level',
  'normal_color', 'charging_color', 'critical_color'
}

function o.draw(o, wibox, cr, width, height)
  local center_x = (width / 2.0) - ((data[o].width + (data[o].stroke_width * 2)) / 2.0)
  local center_y = (height / 2.0) - ((data[o].height + (data[o].stroke_width * 2)) / 2.0)
  cr:translate(center_x, center_y)
  cr:append_path(battery_border_generate({
    width = data[o].width,
    height = data[o].height,
    stroke_width = data[o].stroke_width,
    peg_top = data[o].peg_top,
    peg_height = data[o].peg_height,
    peg_width = data[o].peg_width
  }))

  cr.fill_rule = 'EVEN_ODD'
  local percent = acpi_battery_percent(data[o].battery)

  local draw_color = color(data[o].normal_color)
  if acpi_battery_is_present(data[o].battery) then
    if acpi_battery_is_charging(data[o].battery) then
      draw_color = color(data[o].charging_color)
    elseif percent <= data[o].critical_level then
      draw_color = color(data[o].critical_color)
    end
  end

  -- Draw fill
  cr:translate(data[o].stroke_width, data[o].stroke_width)
  cr:append_path(battery_fill_generate(data[o].width, data[o].height, percent))

  if acpi_is_on_ac_power(data[o].battery) then
    local bolt_x = (data[o].width  / 2.0) - (data[o].bolt_width  / 2.0)
    local bolt_y = (data[o].height / 2.0) - (data[o].bolt_height / 2.0)
    cr:translate( bolt_x,  bolt_y)
    cr:append_path(battery_bolt_generate(data[o].bolt_width, data[o].bolt_height))
    cr:translate(-bolt_x, -bolt_y)
  end
  cr:set_source(draw_color)
  cr:fill()
end

-- Build properties function
for _, prop in pairs(properties) do
  if not o['set_' .. prop] then
    o['set_' .. prop] = function(widget, value)
      data[widget][prop] = value
      widget:emit_signal('widget::updated')
      return widget
    end
  end
end

--- Create an o widget
function o.new(args)
  local args = args or {}
  local battery = args.battery or 'BAT0'
  local stroke_width = args.stroke_width or 2
  local width = args.width or 36
  local height = args.height or 15
  local bolt_width = args.bolt_width or 19
  local bolt_height = args.bolt_height or 11
  local update_frequency = args.update_frequency or 5
  local peg_height = args.peg_height or (height / 3)
  local peg_width = args.peg_width or 2
  local peg_top = args.peg_top or (((height + (stroke_width * 2)) / 2.0) - (peg_height / 2.0))
  local font = args.font or beautiful.font
  local critical_level = args.critical_level or 0.10
  local normal_color = args.normal_color or beautiful.fg_normal
  local critical_color = args.critical_color or '#ff0000'
  local charging_color = args.charging_color or '#00ff00'

  args.type = 'imagebox'

  local widget = base.make_widget()

  --[[local t = gears.timer({timeout = update_frequency})
  t:connect_signal("timeout", function() widget:emit_signal("widget::updated") end)
  t:start()]]

  data[widget] = {
    battery = battery,
    width = width,
    height = height,
    bolt_width = bolt_width,
    bolt_height = bolt_height,
    stroke_width = stroke_width,
    peg_top = peg_top,
    peg_height = peg_height,
    peg_width = peg_width,
    font = font,
    critical_level = critical_level,
    normal_color = normal_color,
    critical_color = critical_color,
    charging_color = charging_color,
  }

  -- Set methods
  for _, prop in pairs(properties) do
    widget['set_' .. prop] = o['set_' .. prop]
  end

  widget.draw = o.draw
  widget.fit = o.fit
  local battery_tooltip
  battery_tooltip = awful.tooltip({
    objects={widget},
    timer_function = function()
      battery_tooltip.text = acpi_battery_runtime(data[widget].battery)
    end
  })
  return widget
end

function o.mt:__call(...)
  return o.new(...)
end

return setmetatable(o, o.mt)
