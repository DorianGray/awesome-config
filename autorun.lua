local awful = require 'awful'


-- Autostart applications
local function run_once(cmd, match)
  if not match then
    match = cmd
    local firstspace = cmd:find(' ')
    if firstspace then
      match = cmd:sub(0, firstspace-1)
    end
  end
  awful.spawn.with_shell(
    '! pgrep -u $USER -x ' .. match .. ' > /dev/null && exec ' .. cmd
  )
end

return function(autorun) 
  for app, config in pairs(autorun) do
    run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
    if config.rules then
      for _, rule in pairs(config.rules) do
        table.insert(awful.rules.rules, rule)
      end
    end
  end
end
