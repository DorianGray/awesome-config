local beautiful = require 'beautiful'
local gears = require 'gears'
local volicon = require 'wibox'.widget.imagebox(beautiful.widget_vol)
local volumewidget = require 'apw.widget'
local oldupdate = volumewidget.Update
volumewidget.Update = function()
  local p = oldupdate()

  local volume = p.Volume * 100
  if p.Mute then
    volicon:set_image(beautiful.widget_vol_mute)
  elseif tonumber(volume) == 0 then
    volicon:set_image(beautiful.widget_vol_no)
  elseif tonumber(volume) <= 50 then
    volicon:set_image(beautiful.widget_vol_low)
  else
    volicon:set_image(beautiful.widget_vol)
  end
end
local volumeupdatetimer = gears.timer({ timeout = 0.5 }) -- set update interval in s
volumeupdatetimer:connect_signal("timeout", volumewidget.Update)
volumeupdatetimer:start()

return {
  icon = volicon,
  widget = volumewidget,
}
