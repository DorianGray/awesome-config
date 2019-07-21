local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local icon = require 'widget.volume.icon.volume'(
  32 * beautiful.scale,
  32 * beautiful.scale
)
local widget = require 'wibox'.widget.imagebox()
local audio = require 'widget.volume.pulseaudio':Create()
local oldupdate = widget.Update
local volume = 0
local muted = false

widget.Update = function()
  audio:UpdateState()
  volume = audio.Volume * 100
  muted = audio.Mute
  widget:set_image(icon(volume, muted))
end

function widget.Up()
  audio:SetVolume(audio.Volume + 0.05)
  widget.Update()
end

function widget.Down()
  audio:SetVolume(audio.Volume - 0.05)
  widget.Update()
end

function widget.ToggleMute()
  audio:ToggleMute()
  widget.Update()
end

function widget.LaunchMixer()
  os.execute('pavucontrol &')
end

local t = gears.timer({ timeout = 5 }) -- set update interval in s
t:connect_signal("timeout", widget.Update)
t:start()
awful.tooltip({
  objects={ widget },
  timer_function = function()
    return (muted and 'Muted\r\n' or '')..'Volume: '..math.floor(volume)..'%'
  end
})

widget:buttons(awful.util.table.join(
		awful.button({ }, 1, widget.ToggleMute),
		awful.button({ }, 3, widget.LaunchMixer),
		awful.button({ }, 4, widget.Up),
		awful.button({ }, 5, widget.Down)
	)
)

widget.Update()
widget:set_image(icon(volume, muted))
return widget
