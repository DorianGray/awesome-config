local wibox = require 'wibox'
local awful = require 'awful'
local beautiful = require 'beautiful'
local string = require 'string'
local table = require 'table'
local theme = require 'theme'
local icon = require 'widget.net.icon.signal'(
  32 * theme.scale,
  32 * theme.scale
)
local mouse = require 'mouse'
local gears = require 'gears'
local form = require 'widget.form'
local form_textbox = require 'widget.form.textbox'

local o = {
  ssid = '',
  connected = false,
  signal = 0,
  frequency = 0,
  encryption = nil,
  internet = true,
}

local generate_menu

local function run(command, callback)
  return awful.spawn.easy_async_with_shell(command, callback)
end

local function read_file(file)
  local f = io.open(file, "rb")
  if f == nil then return false end
  local o = f:read("*all")
  f:close()
  return o
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

local NET_STATUS = {
  UP='connected',
  DOWN='disconnected',
}

local function parse_proc_net_wireless(output)
  local interfaces = {}
  for line in output:gmatch('([^\n]+)') do
    if not line:match('|') then
      local _, _, iface, status, link, level, noise  = line:find('^([^:]+):%s+(%d+)%s+(%d+)%.%s+-(%d+)%.%s+-(%d+)')
      interfaces[iface] = {status=status, link=link, level=level, noise=noise}
    end
  end
  return interfaces
end

local function parse_ip_link(output, cat_output)
  local sep = '\n'
  local groups = {{'INTERFACE', 'TYPE', 'STATUS', ''}}
  local wireless = parse_proc_net_wireless(cat_output)

  local function add_group(group)
    str = table.concat(group, sep)
    local _, _, ifname, iftype, ifstatus = str:find('%d:%s+(%S*):%s+<(%S*)>.*state%s+(%S*)')
    ifstatus = NET_STATUS[ifstatus] or 'unavailable'
    if iftype:match('LOOPBACK') then
      iftype = 'loopback'
      ifstatus = NET_STATUS['UP']
    elseif wireless[ifname] then
      iftype = 'wireless'
    elseif iftype:match('BROADCAST,MULTICAST') then
      iftype = 'ethernet'
    else
      iftype = 'unknown'
    end
    groups[#groups+1] = {ifname, iftype, ifstatus, ''}
  end

  local group = {}
  for str in string.gmatch(output, '([^'..sep..']+)') do
    if str:match('^%d:') and #group > 0 then
      add_group(group)
      group = {str}
    else
      group[#group+1]=str
    end
  end
  add_group(group)

  return groups
end

--Make a table of the local interfaces
local function get_local_interfaces(cb)
  run('ip link', function(output)
    cb(parse_ip_link(output, read_file('/proc/net/wireless')))
  end)
end

local function get_wifi_link(iface, cb)
  local wireless = parse_proc_net_wireless(read_file('/proc/net/wireless'))
  run('wpa_cli status', function(wpa_output)
    local info = {}
    for line in wpa_output:gmatch('([^\n]+)') do
      local _, _, key, value = line:find('^([^=]*)=([^=]*)$')
      if key then
        info[key] = value
      end
    end
    return cb({
      ssid=info.ssid,
      signal=tonumber(wireless[iface[1]].level),
      frequency=tonumber(info.freq),
    })
  end)
end

local scan_timer = nil
--make a table of the scanned wifis
local function get_area_wifi(widget, iface, cb)
  run('wpa_cli abort_scan && wpa_cli scan', function(scan_output)
    if scan_output:match('FAIL') then
      if scan_timer and scan_timer.started then
        scan_timer:stop()
      end
      cb({})
    end
    if scan_timer and scan_timer.started then
      return
    end
    if not scan_timer then
      scan_timer = gears.timer({
        timeout   = 1,
        autostart = false,
        callback  = function()
          run('wpa_cli scan_results', function(output)
            local _, count = output:gsub('\n', '\n')
            if count <= 3 then
              if scan_timer.started then
                scan_timer.timeout = 3
                return
              end
            end
            scan_timer:stop()
            local networks = {}
            local skip = 1
            for line in output:gmatch('[^\r\n]+') do
              if skip <= 2 then
                skip = skip + 1
              else
                local _, _, bssid, frequency, signal, encryption, ssid = line:find("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")
                table.insert(networks, {
                  bssid=bssid,
                  frequency=tonumber(frequency),
                  signal=tonumber(signal),
                  encryption=encryption,
                  ssid=ssid,
                })
              end
            end
            cb(networks)
          end)
        end
      })
    end
    scan_timer:start()
  end)
end

local function connect_wifi(ssid, security, cb)
  local panel = mouse.screen.right_panel
  local wifi_widget = wibox.widget({
    layout=wibox.layout.grid,
    homogeneous=true,
    spacing=0,
    min_cols_size=2,
    min_rows_size=1,
  })

  local row = 1
  wifi_widget:add_widget_at(wibox.widget.textbox('SSID: '), row, 1)
  wifi_widget:add_widget_at(wibox.widget.textbox(ssid), row, 2)
  row = row + 1
  if security then
    wifi_widget:add_widget_at(wibox.widget.textbox('Security: '), row, 1)
    wifi_widget:add_widget_at(wibox.widget.textbox(security), row, 2)
    row = row + 1
    wifi_widget:add_widget_at(wibox.widget.textbox('Password: '), row, 1)
    local wifi_form = form(function(self)
      panel:toggle_visible(false)
      self:set_active_input(nil)
    end)
    local password_box = form_textbox(wifi_form, 'password')
    password_box.type = 'password'
    wifi_form:set_active_input(password_box.widget)
    wifi_widget:add_widget_at(password_box, row, 2)
    row = row + 1
  end

  panel:set_content(wifi_widget)
  panel:toggle_visible(true)
end

local function toggle_interface(iface, cb)
  get_local_interfaces(function(interfaces)
    for _, interface in pairs(interfaces) do
      if interface[1] == iface then 
        local action = interface[3] == 'connected'  and 'down' or 'up'
        local command = 'sudo ip link set dev '..iface..' '..action
        run(command, function(output)
          cb(output)
        end)
      end
    end
  end)
end

local function disconnect_wifi(cb)

end

local function toggle_wifi(widget, iface, cb)
  run('sudo rfkill -r -n', function(output)
    local rfkill = {}
    for line in output:gmatch("[^\r\n]+") do
      local interface = {}
      for str in line:gmatch("%w+") do
        table.insert(interface, str)
      end
      table.insert(rfkill, interface)
    end

    for _, interface in pairs(rfkill) do
      local index, wtype, name, softblock, hardblock = interface[1], interface[2], interface[3], interface[4] == 'blocked' and true or false, interface[5] == 'blocked' and true or false
      if wtype == 'wlan' then
        local action = 'block'
        if softblock or hardblock then
          action = 'unblock'
        else
          o.connected = false
          o.signal = 0
          o.ssid = ''
          o.frequency = 0
        end
        run('sudo rfkill '..action..' '..wtype, function()
          generate_menu(widget, cb)
        end)
        return
      end
    end
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
  local data = {lt.encryption, lt.ssid, lt.signal, lt.frequency}
  local line = {}
  local lengths = {
    -1,
    -1,
    false,
    false,
  }
  local fields = {
    function(v)
      return v ~= '[ESS]' and '✓ ' or 'x ' 
    end,
    true,
    false,
  }

  return generate_line(lengths, fields, data, skip_replace)
end

local function generate_iface_line(lt, skip_replace, last)
  lt = {lt[3], lt[1], lt[4], lt[5]}
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
      if v:match('disconnected') or v:match('unavailable') then
        return '✗'
      elseif v:match('connected') then
        return '✓'
      elseif v:match('connecting') then
        return ' ❗  '
      end
      return '     '
    end,
    function(v, list)
      if lt[4] == 'last' then
        return '╰╴'..v
      else
        return '├╴'..v
      end
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

local function generate_wifi_menu(widget, iface, networks, cb)
  get_wifi_link(iface, function(link)
    o.connected = link and true or false
    if o.connected then
      o.signal = link.signal
      o.ssid = link.ssid
      o.frequency = link.frequency
    else
      o.signal = 0
      o.ssid = ''
      o.frequency = 0
    end
    widget:set_image(icon(o.signal, 0--[[o.frequency]], o.connected, o.internet))

    get_area_wifi(widget, iface, function(area_wifi)
      local wifi_list = {}
      table.sort(area_wifi, function(a, b) return (math.abs(a.signal) or 100) > (math.abs(b.signal) or 100) end)

      table.insert(wifi_list, {generate_wifi_line({encryption='⚷ ', ssid='SSID'}, true)})
      for i, lt in ipairs(area_wifi) do 
        local work = {
          generate_wifi_line(lt),
          function()
            connect_wifi(lt.ssid, lt.encryption, function()
              generate_menu(widget, cb)
            end)
          end,
          icon(math.abs(lt.signal), lt.frequency, true, true)
        }
        table.insert(wifi_list, work)
      end

      table.insert(wifi_list, {'Rescan', function()
        generate_menu(widget, cb)
      end})
      table.insert(wifi_list, {'Disconnect', function()
        disconnect_wifi(iface[1], function()
          generate_menu(widget, cb)
        end)
      end})
      table.insert(wifi_list, {'Toggle Interface', function()
        toggle_wifi(widget, iface[1], function()
          generate_menu(widget, cb)
        end)
      end})
      local face = {generate_iface_line(iface), wifi_list}
      local found = nil
      for key, face1 in pairs(networks) do
        if face1[1] == face[1] then
          found = key
          break
        end
      end
      if found then
        networks[found] = face
      else
        table.insert(networks, face)
      end
      cb(networks)
    end)
  end)
end

--generate the network menu
generate_menu = function(widget, cb)
  get_local_interfaces(function(local_interfaces)
    local networks = {}
    --Sort by network type
    table.sort(local_interfaces, function(a, b) return a[2] < b[2] end)
    local last_iface = nil
    for key in ipairs(local_interfaces) do
      local iface = local_interfaces[key]
      -- Insert type separator(ie: BRIDGE)
      if key ~= 1 and last_iface ~= iface[2] then
        iface[5] = 'new'
        last_iface = iface[2]
        table.insert(networks, {last_iface:upper()})
      else
        iface[5] = 'current'
      end
      if key >= #local_interfaces or local_interfaces[key+1][2] ~= last_iface then
        iface[5] = 'last'
      end

      if iface[2] == 'wireless' then
        -- wifi interfaces
        generate_wifi_menu(widget, iface, networks, cb)
      elseif key ~= 1 then
        --any network interface that is not the header and does not have a submenu
        local face = {generate_iface_line(iface), function()
          toggle_interface(iface[1], function()
            generate_menu(widget, cb)
          end)
        end}
        table.insert(networks, face)
      end
      cb(networks)
    end
  end)
end

local function menu(args, widget)
  generate_menu(widget, function(items)
    args.menu = awful.menu({
      theme = {
        height = beautiful.menu_height,
        width = beautiful.menu_width,
      },
      items = items
    })
    widget:emit_signal('widget::updated')
  end)
end

function o.widget(promptbox)
  o.promptbox = promptbox

  local args = {
    image = icon(o.signal, 0 --[[o.frequency]], o.connected, o.internet),
    menu = awful.menu(),
  }

  local widget = awful.widget.launcher(args)
  menu(args, widget)
  awful.tooltip({
    objects={ widget },
    timer_function = function()
      if o.ssid then
        return o.ssid..'\n'..tostring(o.frequency):sub(1, 1)..'ghz'
      else
        return 'Not Connected'
      end
    end
  })
  gears.timer({
    timeout=10,
    autostart=true,
    callback=function()
      get_net_status(function(internet)
        o.internet = internet
        get_wifi_link({'wlp2s0'}, function(link)
          o.connected = link and true or false
          if o.connected then
            o.signal = link.signal
            o.ssid = link.ssid
            o.frequency = link.frequency
          else
            o.signal = 0
            o.ssid = ''
            o.frequency = 0
          end
          widget:set_image(icon(o.signal, 0--[[o.frequency]], o.connected, o.internet))
        end)
      end)
    end,
  })
  return widget
end

return o
