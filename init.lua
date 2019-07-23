-- Add local luarocks repo to package.path
package.path = os.getenv('HOME')..'/.luarocks/share/lua/5.1/?.lua;'..os.getenv('HOME')..'/.luarocks/share/lua/5.1/?/init.lua;'..package.path
package.cpath = os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?.so;'..os.getenv('HOME')..'/.luarocks/lib/lua/5.1/?/init.so;'..package.cpath

--early init
local awesome = require 'awesome'
local error_handler = require 'error_handler'
local config = require 'config'
local beautiful = require 'beautiful'
-- beautiful init, just after error handling for styling errors early
local theme = require('theme.' .. config.theme)
beautiful.init(theme)

error_handler.setup(awesome)
