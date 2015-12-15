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
  awful.spawn.with_shell('pgrep -u $USER -x ' .. match .. ' > /dev/null || (' .. cmd .. ')')
end

local autorun = true
local autorunApps = { 
  ['google-chrome'] = {cmd=false, match='chrome'},
  ['gnome-terminal'] = {cmd='-e "/home/awesome/.config/awesome/tmux-session.sh awesome"', match='gnome-terminal-'},
  ['gnome-settings-daemon'] = {match='gnome-settings-'},
  ['unclutter'] = {cmd='-root'},
--  ['urxvtd'] = {},
}
if autorun then
  for app, config in pairs(autorunApps) do
    run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
  end
end
