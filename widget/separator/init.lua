local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")

local separators = {}

local height = beautiful.awful_widget_height or 0
local width  = beautiful.separators_width or 9

function separators.arrow_right(col1, col2)
    local widget = wibox.widget.base.make_widget()

    widget.fit = function(m, w, h) return width, height end

    widget.draw = function(mycross, wibox, cr, width, height)
        if col2 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(col2))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(width, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(0, height)
            cr:line_to(width, height/2)
            cr:line_to(width, height)
            cr:close_path()
            cr:fill()
        end

        if col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(col1))
            cr:new_path()
            cr:move_to(0, 0)
            cr:line_to(width, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end
   end

   return widget
end

function separators.arrow_left(col1, col2)
    local widget = wibox.widget.base.make_widget()

    widget.fit = function(m, w, h) return width, height end

    widget.draw = function(mycross, wibox, cr, width, height)
        if col1 ~= "alpha" then
            cr:set_source_rgb(gears.color.parse_color(col1))
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(0, 0)
            cr:close_path()
            cr:fill()

            cr:new_path()
            cr:move_to(width, height)
            cr:line_to(0, height/2)
            cr:line_to(0, height)
            cr:close_path()
            cr:fill()
        end

        if col2 ~= "alpha" then
            cr:new_path()
            cr:move_to(width, 0)
            cr:line_to(0, height/2)
            cr:line_to(width, height)
            cr:close_path()

            cr:set_source_rgb(gears.color.parse_color(col2))
            cr:fill()
        end
   end

   return widget
end

return separators
