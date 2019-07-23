local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local icon = require 'widget.volume.icon.volume'(
  32 * beautiful.scale,
  32 * beautiful.scale
)
local widget = require 'wibox'.widget.imagebox()
local audio = require 'widget.volume.pulseaudio'()
local oldupdate = widget.update
local volume = 0
local muted = false

widget.update = function()
  audio:update()
  volume = audio.volume * 100
  muted = audio.is_muted
  widget:set_image(icon(volume, muted))
end

function widget.up()
  audio:set_volume(audio.volume + 0.05)
  widget.update()
end

function widget.down()
  audio:set_volume(audio.volume - 0.05)
  widget.update()
end

function widget.toggle_mute()
  audio:toggle_mute()
  widget.update()
end

function widget.launch()
  os.execute('pavucontrol &')
end

local t = gears.timer({ timeout = 5 }) -- set update interval in s
t:connect_signal("timeout", widget.update)
t:start()
awful.tooltip({
  objects={ widget },
  timer_function = function()
    return (muted and 'Muted\r\n' or '')..'Volume: '..math.floor(volume)..'%'
  end
})

widget:buttons(awful.util.table.join(
		awful.button({ }, 1, widget.toggle_mute),
		awful.button({ }, 3, widget.launch),
		awful.button({ }, 4, widget.up),
		awful.button({ }, 5, widget.down)
	)
)

widget.update()
widget:set_image(icon(volume, muted))
widget.keys = {
    awful.key({ }, "XF86AudioRaiseVolume",  widget.up),
    awful.key({ }, "XF86AudioLowerVolume",  widget.down),
    awful.key({ }, "XF86AudioMute",         widget.toggle_mute),
}
 
return widget
