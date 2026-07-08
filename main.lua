local root = "./lua_modules"
package.path = root .. "/share/lua/5.1/?.lua;" .. root .. "/share/lua/5.1/?/init.lua;" .. package.path
package.cpath = root .. "/lib/lua/5.1/?.so;" .. package.cpath
package.path = root .. "/share/lua/5.5/?.lua;" .. root .. "/share/lua/5.5/?/init.lua;" .. package.path
package.cpath = root .. "/lib/lua/5.5/?.so;" .. package.cpath

local bufo_runner = require("bufo.runner")
bufo_runner.run({
    files = {
        "./src/a.test.lua"
    }
})
