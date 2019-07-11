local wibox = require 'wibox'
local gears = require 'gears'
local keygrabber = require 'widget.form.keygrabber'

return function(submit)
  local o = wibox.widget({
    layout=wibox.layout.grid,
    homogeneous=false,
    spacing=5,
    min_cols_size=2,
    min_rows_size=1,
    _active_input = nil,
    _grabber = nil,
    _data = {},
  })
  o._grabber = keygrabber(o)

  function o:set_active_input(input)
    if input == nil or not input._accepts_input then
      input = nil
    end

    if self._active_input ~= nil then
      self._active_input:deactivate()
      self._grabber:stop()
    end

    self._active_input = input

    if input ~= nil then
      input:activate()
      self._grabber:start()
    end
  end

  function o:submit() end
  if submit ~= nil then o.submit = submit end

  return o
end
