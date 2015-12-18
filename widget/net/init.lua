local wibox = require 'wibox'
local awful = require 'awful'
local gears = require 'gears'
local naughty = require 'naughty'
local beautiful = require 'beautiful'
local string = require 'string'
local table = require 'table'
local asyncshell = require 'lain.asyncshell'
local icons = require 'widget.net.icon.wifi'(32,32)
local lgi = require 'lgi'

local o = {connected = false, signal = 0, internet = true}

local function run(command, callback)
  return asyncshell.request(command, callback)
end

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function parse_command(input)
  local sep = '\n'
  local t = {};
  local first = true
  local keys = {}
  for str in string.gmatch(input, '([^'..sep..']+)') do
    if first then
      first = false
      local start, finish = str:find('[%S]+', finish)
      local _, finish = str:find('%s+', finish)
      while start do
        keys[#keys+1] = {start, finish}
        start, finish = str:find('[%S]+', finish)
        _, finish = str:find('%s+', finish)
      end
    end

    local result = {}
    for _, key in pairs(keys) do
      result[#result+1] = trim(str:sub(unpack(key)))
    end
    t[#t+1] = result
  end
  return t
end

local function get_net_status(cb)
  local times = 0
  local function ping()
    run('ping -c 1 -W 1 8.8.8.8 | grep \'100% packet loss\'', function(output)
      if output ~= "" and times <= 4 then
        times = times + 1
        ping()
      else
        cb(output == "")
      end
    end)
  end
  ping()
end

--Make a table of the local interfaces
local function get_local_interfaces(cb)
  run('nmcli device', function(output)
    cb(parse_command(output))
  end)
end

--make a table of the scanned wifis
local function get_area_wifi(cb)
  run('nmcli --fields SECURITY,SSID,SIGNAL,IN-USE device wifi', function(output)
    cb(parse_command(output))
  end)
end

local function connect_wifi(ssid, security, cb)
  run('nmcli --fields NAME connection', function(output)
    local ot = parse_command(output)
    local found = false
    for _, v in pairs(ot) do
      if v[1] == ssid then
        found = true
        break
      end
    end
    if found then
      run('nmcli connection up '..ssid, function(output) end)
    else
      if security == "--" then
        run('nmcli device wifi connect '..ssid, function(output)
          cb(output)
        end)
      else
        awful.prompt.run({ prompt = "Password for "..ssid..": " },
        o.promptbox[mouse.screen].widget, function(password)
          run('nmcli device wifi connect '..ssid..' password '..password, function(output)
            cb(output)
          end)
        end)
      end
    end
  end)
end

local function toggle_interface(iface, cb)
  get_local_interfaces(function(interfaces)
    for _, interface in pairs(interfaces) do
      if interface[1] == iface then 
        local action = iface[2] == 'connected' and 'disconnect' or 'connect'
        run('nmcli device '..action..' '..iface, function(output)
          cb(output)
        end)
      end
    end
  end)
end

local function toggle_wifi(cb)
  run('nmcli radio wifi', function(output)
    local action = trim(output) == 'enabled' and 'off' or 'on'
    run('nmcli radio wifi '..action, function(output)
      local function scan()
        run('sleep 1', function()
          run('nmcli device wifi rescan', function(output)
            if output == "" then
              cb(output)
            else
              scan()
            end
          end)
        end)
      end
      if action == "on" then
        scan()
      else
        cb(output)
      end
    end)
  end)
end

local function generate_line(lengths, fields, lt, skip_replace)
  local line = {}
  for i, len in ipairs(lengths) do
    local v = lt[i]
    if not skip_replace and type(fields[i]) == 'function' then
      v = fields[i](v)
    end
    if len then
      if len < 0 then
        line[#line+1] = v
      elseif #v > len then
        line[#line+1] = v:sub(1, len-3)..'...'..(' '):rep(3)
      else
        line[#line+1] = v..(" "):rep(len+3-#v)
      end
    end
  end
  return table.concat(line)
end

local function generate_wifi_line(lt, skip_replace)
  local line = {}
  local lengths = {
    -1,
    -1,
    false,
    false,
  }
  local fields = {
    function(v)
      return v:match('[^-]') and '✓ ' or 'x ' 
    end,
    true,
    false,
  }

  return generate_line(lengths, fields, lt, skip_replace)
end

local function generate_iface_line(lt, skip_replace, last)
  lt = {lt[3], lt[1], lt[4]}
  if lt[2] == lt[3] then
    lt[3] = ''
  end
  local lengths = {
    -1,
    -1,
    -1,
  }
  local fields = {
    function(v)
      if v:match('connected') then
        return '✓'
      elseif v:match('disconnected') or v:match('unavailable') then
        return 'x'
      end
      return '  '
    end,
    function(v, list)
      return ' └╴'..v
    end,
    function(v)
      if v:match('%-%-') then
        return ''
      end
      return ' '..v
    end,
  }

  return generate_line(lengths, fields, lt, skip_replace)
end

local function unique_wifi(wifi)
  local ssids = {}
  for _, v in pairs(wifi) do
    local ssid = ssids[v[2]]
    if not ssid then
      ssids[v[2]] = v
    elseif v[4] == "*" or (ssid[4] ~= "*" and tonumber(v[3]) > tonumber(ssid[3])) then
      ssids[v[2]] = v
    end
  end
  local res = {}
  for _, v in pairs(ssids) do
    res[#res+1] = v
  end
  return res
end

local generate_menu

local function generate_wifi_menu(iface, networks, cb)
  get_area_wifi(function(area_wifi)
    local wifi_list = {}
    local wificonnected = false
    local wifisignal = 0
    local wifissid = ''
    local wifisecurity = nil
    area_wifi = unique_wifi(area_wifi)
    table.sort(area_wifi, function(a,b) return (tonumber(a[3]) or 100) > (tonumber(b[3]) or 100) end)
    for i, lt in ipairs(area_wifi) do
      local ssid, signal, security, in_use = lt[2], tonumber(lt[3]), lt[1], lt[4]
      if signal then
        if in_use == '*' then
          wificonnected = true
          wifisignal = signal
          wifissid = ssid
          wifisecurity = security
        else
          local work = {
            generate_wifi_line(lt),
            function()
              connect_wifi(ssid, security, function()
                generate_menu(cb)
              end)
            end,
            icons.from_signal(signal)
          }
          table.insert(wifi_list, work)
        end
      else
        table.insert(wifi_list, {generate_wifi_line({'🔒 ', 'SSID', nil, nil}, true)})
      end
    end
    local ud = {'Toggle Interface', function()
      toggle_wifi(function()
        generate_menu(cb)
      end)
    end}
    table.insert(wifi_list, ud)
    local ud = {'Rescan', function()
      generate_menu(cb)
    end}
    table.insert(wifi_list, ud)
    local face = {generate_iface_line(iface), wifi_list}
    table.insert(networks, face)
    o.connected = wificonnected
    o.signal = wifisignal
    o.ssid = wifissid
    o.security = wifisecurity
    cb(networks)
  end)
end

--generate the network menu
generate_menu = function(cb)
  get_local_interfaces(function(local_interfaces)
    local networks = {}
    --Sort by network type
    table.sort(local_interfaces, function(a, b) return a[2] < b[2] end)
    local last_iface = nil
    for key, iface in ipairs(local_interfaces) do
      -- Insert type separator(ie: BRIDGE)
      if key ~= 1 and last_iface ~= iface[2] then
        last_iface = iface[2]
        table.insert(networks, {last_iface:upper()})
      end
      if iface[2] == 'wifi' then
        -- wifi interfaces
        generate_wifi_menu(iface, networks, cb)
      elseif key ~= 1 then
        --any network interface that is not the header and does not have a submenu
        local face = {generate_iface_line(iface), function()
          toggle_interface(iface[1], function()
            generate_menu(cb)
          end)
        end}
        table.insert(networks, face)
      end
      cb(networks)
    end
  end)
end

local function menu(args, widget)
  generate_menu(function(items)
    args.menu = awful.menu({
      theme = {
        height = 16,
        width = 150,
      },
      items = items
    })
    if not o.connected then
      widget:set_image(icons.disconnected)
    else
      widget:set_image(icons.from_signal(o.signal, not o.internet))
    end
    widget:emit_signal('widget::updated')
  end)
end

function o.widget(promptbox)
  o.promptbox = promptbox

  local args = {
    image = icons.from_signal(0, true),
    menu = awful.menu(),
  }

  local widget = awful.widget.launcher(args)
  menu(args, widget)
  local t = gears.timer({timeout = 15})
  t:connect_signal("timeout", function() menu(args, widget) end)
  t:start()
  local t = gears.timer({timeout = 10})
  t:connect_signal("timeout", function()
    get_net_status(function(up)
      o.internet = up
      if not up then
        widget:set_image(icons.from_signal(o.signal, true))
      else
        widget:set_image(icons.from_signal(o.signal))
      end
      widget:emit_signal('widget::updated')
    end)
  end)
  t:start()
  awful.tooltip({
    objects={ widget },
    timer_function = function()
      return o.ssid
    end
  })
  return widget
end

return o
