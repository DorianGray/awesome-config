local awful = require 'awful'
local gears = require 'gears'
local util = require 'util'

local themes_dir = util.script_path()
local scale = 2
local font_size_int = 20 * scale
local font_size = font_size_int..'px'
local font_name = "Hack Bold"

local theme = {
  scale = scale,
  taskbar_height = 32,
  wallpaper = themes_dir .. "wall.jpg",

  font_name = font_name,
  font_size_int = font_size_int,
  font_size = font_size,
  font = table.concat({
    	font_name,
    	font_size,
  }, ' '),
  fg_normal = "#DDDDFF",
	fg_focus = "#FFFFFF",
	fg_urgent = "#CC9393",
	bg_normal = "#1A1A1A",
	bg_focus = "#313131",
	bg_urgent = "#1A1A1A",
	border_width= 0,
	border_normal = "#3F3F3F",
	border_focus = "#7F7F7F",
	mouse_finder_color = "#CC9393",
	menu_height = 32 * scale,
	menu_width  = 280 * scale,

	taglist_squares_sel = themes_dir .. "icons/square_sel.png",
	taglist_squares_unsel = themes_dir .. "icons/square_unsel.png",

	layout_tile = themes_dir .. "icons/tile.png",
	layout_tilegaps = themes_dir .. "icons/tilegaps.png",
	layout_tileleft = themes_dir .. "icons/tileleft.png",
	layout_tilebottom = themes_dir .. "icons/tilebottom.png",
	layout_tiletop = themes_dir .. "icons/tiletop.png",
	layout_fairv = themes_dir .. "icons/fairv.png",
	layout_fairh = themes_dir .. "icons/fairh.png",
	layout_spiral = themes_dir .. "icons/spiral.png",
	layout_dwindle = themes_dir .. "icons/dwindle.png",
	layout_max = themes_dir .. "icons/max.png",
	layout_fullscreen = themes_dir .. "icons/fullscreen.png",
	layout_magnifier = themes_dir .. "icons/magnifier.png",
	layout_floating = themes_dir .. "icons/floating.png",

	tasklist_disable_icon = false,
	tasklist_floating = "",
	tasklist_maximized_horizontal = "",
	tasklist_maximized_vertical = "",

	command = {
    lock = function()
      awful.spawn.with_shell('/usr/local/bin/lock-screen')
    end,
    logout = function()
      awful.spawn.with_shell('sudo /usr/local/bin/logout')
    end,
    shutdown = function()
      awful.spawn.with_shell('sudo openrc-shutdown -p now')
    end,
    reboot = function()
      awful.spawn.with_shell('sudo openrc-shutdown -r now')
    end,
  },
}

-- Wallpaper
if theme.wallpaper then
  for s in screen do
    gears.wallpaper.maximized(theme.wallpaper, s, true)
  end
end

return theme
