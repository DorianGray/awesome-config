local naughty = require 'naughty'

local function setup(awesome)
  -- Error handling
  if awesome.startup_errors then
    naughty.notify({
      preset = naughty.config.presets.critical,
      title = 'Oops, there were errors during startup!',
      text = awesome.startup_errors,
    })
  end

  local in_error = false
  awesome.connect_signal('debug::error', function (err)
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = 'Oops, an error occurred!',
      text = debug.traceback(err),
    })
    in_error = false
  end)
end

return {
  setup = setup,
}
