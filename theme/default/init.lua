local gears = require 'gears'
local util = require 'util'
local process = require 'awful.io.process'

local themes_dir = util.script_path()
local scale = 2
local font_size_int = 20 * scale
local font_size = font_size_int..'px'
local font_name = "Hack Bold"

local theme = {
  scale = scale,
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
	wibar = {
    height = 32 * scale,
  },
	menu_height = 32 * scale,
	menu_width  = 280 * scale,

	taglist_squares_sel = themes_dir .. "icons/square_sel.png",
	taglist_squares_unsel = themes_dir .. "icons/square_unsel.png",

	layout_tile = require 'widget.layout.icon.tile'(32, 32)(),
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

  alttab = { 
    preview_box = true,
    preview_box_bg = "#ddddddaa",
    preview_box_border = "#22222200",
    preview_box_fps = 30,
    preview_box_delay = 150,

    client_opacity = false,
    client_opacity_value = 0.5,
    client_opacity_delay = 150,
  },

  battery = {
    width = 30 * scale,
    height = 10 * scale,
    bolt_width = 30 * scale,
    bolt_height = 15 * scale,
    stroke_width = 2 * scale,
    peg_top = 4 * scale,
    peg_height = 6 * scale,
    peg_width = 4 * scale,
    font = font,
    critical_level = 0.10,
  },

	command = {
    lock = function()
      process.run('/usr/local/bin/lock-screen')
    end,
    logout = function()
      process.run('sudo /usr/local/bin/logout')
    end,
    shutdown = function()
      process.run('sudo openrc-shutdown -p now')
    end,
    reboot = function()
      process.run('sudo openrc-shutdown -r now')
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
