-- package.path = library_dir .. "/?.lua"
package.path = "/Users/mrxzx/Development/DioxusLabs/plugin-dev/plugin-library/library/?.lua"

local plugin = require("plugin")
local manager = require("manager")

local log = plugin.log
local os = plugin.os
local network = plugin.network
local dirs = plugin.dirs
local path = plugin.path
local fs = plugin.fs

-- plugin information
manager.name = "Dioxus Binaryen"
manager.repository = "https://github.com/mrxiaozhuox/dioxus-binaryen-plugin"
manager.author = "YuKun Liu <mrxzx.info@gmail.com>"
manager.version = "0.0.1"

-- init manager plugin api
plugin.init(manager)

local config = plugin.get_config()

manager.on_init = function ()
    log.info("[Binaryen] First time run, start to download binaryen file.")
    local platform = os.current_platform()

    local file_name = "binaryen-version_110-x86_64-" .. platform .. ".tar.gz"
    local temp_name = path.join(dirs.temp_dir(), "binaryen.tar.gz")

    local status = network.download_file(
        "https://github.com/WebAssembly/binaryen/releases/download/version_110/" .. file_name,
        temp_name
    )
    if not status then
        log.error("binaryen package download failed.")
        return false
    end
    
    local untar = fs.untar_gz_file(temp_name, dirs.bin_dir())
    if not untar then
        log.error("binaryen package install (unpackage) failed.")
        return false
    end

    return true
end

---@param info BuildInfo
manager.build.on_start = function (info)
    -- before the build work start, system will execute this function.
    log.info("[plugin] Build starting: " .. info.name)
end

---@param info BuildInfo
manager.build.on_finish = function (info)
    -- when the build work is done, system will execute this function.
    log.info("[plugin] Build finished: " .. info.name)
end

---@param info ServeStartInfo
manager.serve.on_start = function (info)
    -- this function will after clean & print to run, so you can print some thing.
    log.info("[plugin] Serve start: " .. info.name)
end

---@param info ServeRebuildInfo
manager.serve.on_rebuild = function (info)
    -- this function will after clean & print to run, so you can print some thing.
    local files = plugin.tool.dump(info.changed_files)
    log.info("[plugin] Serve rebuild: '" .. files .. "'")
end

manager.serve.on_shutdown = function ()
    log.info("[plugin] Serve shutdown")
end

manager.serve.interval = 1000

return manager