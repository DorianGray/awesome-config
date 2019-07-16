local awful     = require("awful")

local function outputs(cb)
  local outputs = {}
  awful.spawn.easy_async('xrandr -q --current', function(output)
    local current = nil
    for line in output:gmatch('[^\r\n]+') do
      if not line:match('^Screen') then
        local new_output = line:match('^([%w-]+) connected')
        if new_output then
          current = {resolutions={}, preferred=nil, selected=nil}
          outputs[new_output] = current
        else
          local _, _, width, height, refresh, selected, preferred = line:find('^%s+([^x%s]+)x([^x%s]+)%s+([^%s*+]+)(*?)%s?([+]?)')
          local resolution = {width=tonumber(width), height=tonumber(height), refresh=tonumber(refresh)}
          table.insert(current.resolutions, resolution)
          if selected == '*' then
            current.selected = resolution
          end
          if preferred == '+' then
            current.preferred = resolution
          end
        end
      end
    end

    return cb(outputs)
  end)
end

return {
   outputs = outputs,
}
