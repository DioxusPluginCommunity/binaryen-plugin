package.path = library_dir .. "/?.lua"

local plugin = require("plugin")
local manager = require("manager")

local log = plugin.log
local os = plugin.os
local network = plugin.network
local dirs = plugin.dirs
local path = plugin.path
local fs = plugin.fs
local command = plugin.command

-- plugin information
manager.name = "dioxus-binaryen"
manager.repository = "https://github.com/mrxiaozhuox/dioxus-binaryen-plugin"
manager.author = "YuKun Liu <mrxzx.info@gmail.com>"
manager.version = "0.0.1"

-- init manager plugin api
plugin.init(manager)

local config = plugin.get_config()

manager.on_init = function()
    log.info("[Binaryen] First time run, start to download binaryen file.")
    local platform = os.current_platform()

    local file_name = "binaryen-version_113-x86_64-" .. platform .. ".tar.gz"
    local temp_name = path.join(dirs.temp_dir(), "binaryen.tar.gz")

    local status = network.download_file(
        "https://github.com/WebAssembly/binaryen/releases/download/version_113/" .. file_name,
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
manager.build.on_start = function(info) end

---@param info BuildInfo
manager.build.on_finish = function(info)
    local optimize = config["optimize"]
    if not optimize then
        return
    end

    local command_file = path.join(path.join(path.join(dirs.bin_dir(), "binaryen-version_113"), "bin"), "wasm-opt")
    local file_name = path.join(path.join(path.join(info.out_dir, "assets"), "dioxus"), info.name .. "_bg.wasm")
    if path.is_file(file_name) then
        command.exec({
            command_file,
            file_name,
            "-o",
            file_name,
        }, "inhert", "inhert")
    else
        log.info("File not found")
    end
end

---@param info ServeStartInfo
manager.serve.on_start = function(info)
    -- this function will after clean & print to run, so you can print some thing.
    log.info("[plugin] Serve start: " .. info.name)
end

---@param info ServeRebuildInfo
manager.serve.on_rebuild = function(info) end

manager.serve.on_shutdown = function() end

manager.serve.interval = 1000

return manager