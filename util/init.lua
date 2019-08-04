local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local function table_values(t)
  local values = {}
  for _, v in pairs(t) do
    table.insert(values, v)
  end
  return values
end

return {
  script_path = script_path,
  table = {
    values = table_values,
  },
  autorun = require 'util.autorun',
}
