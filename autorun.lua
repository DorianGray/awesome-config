local awful = require 'awful'
local tags = require 'tags'

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

local autorun = { 
  ['google-chrome-unstable'] = {
    cmd=table.concat({
      '--enable-vulkan',
      '--process-per-site',
      '--high-dpi-support=1',
      '--force-device-scale-factor=2',
      '--touch-events=enabled',
      '--enable-native-gpu-memory-buffers',
      '--enable-zero-copy',
    }, ' '),
    match='chrome',
    rules={
      {
        rule = {class = 'google-chrome-unstable', class = 'Google-chrome-unstable'},
        callback = function(c)
          local s, t = 1, 2
          if screen.count() >= 2 then
            s, t = 2, 1
          end
          c:tags({tags[s][t]})
          c:geometry({
            width = screen[s].workarea.width,
            height = screen[s].workarea.height,
          })
        end,
      },
    },
  },
  ['alacritty'] = {
    cmd=table.concat({
      '-t Terminal',
      '-e '..os.getenv('HOME')..'/.config/awesome/tmux-session.sh awesome',
    }, ' '),
    rules={
      {
        rule = {class = 'alacritty'},
        properties = {
          tag = tags[1][1],
          width = screen[1].workarea.width,
          height = screen[1].workarea.height,
        },
      },
    },
  },
  ['udiskie'] = {},
  ['pulseaudio'] = {cmd='-D'},
  ['unclutter'] = {cmd='-root'},
  ['xautolock'] = {
    cmd=table.concat({
      '-time 5',
      '-detectsleep',
      '-locker /usr/local/bin/xautolocker',
    }, ' '),
  },
}

return function()
  for app, config in pairs(autorun) do
    run_once(app..(config.cmd and ' '..config.cmd or ''), config.match)
    if config.rules then
      for _, rule in pairs(config.rules) do
        table.insert(awful.rules.rules, rule)
      end
    end
  end
end
