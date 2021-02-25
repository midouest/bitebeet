local Installer = {
    PLUGIN = {
        BASE_URL = "https://github.com/midouest/bytebeat/releases/download/",
        VERSION = "0.0.2",
        NAME = "ByteBeat",
        ASSET_EXT = ".tar.gz"
    },
    STAGING_DIR = "/tmp/",
    INSTALL_DIR = "/home/we/.local/share/SuperCollider/Extensions/"
}

local State = {
    NOT_INSTALLED = 0,
    DOWNLOADING = 1,
    INSTALLING = 2,
    SHUTTING_DOWN = 3,
    INSTALLED = 4
}

local state = State.NOT_INSTALLED

local function get_asset_filename()
    return Installer.PLUGIN.NAME .. Installer.PLUGIN.ASSET_EXT
end

local function get_url()
    local asset = get_asset_filename()
    return Installer.PLUGIN.BASE_URL .. Installer.PLUGIN.VERSION .. "/" .. asset
end

local function get_download_cmd(url)
    return "wget -q -P " .. Installer.STAGING_DIR .. " " .. url
end

local function download_plugin(callback)
    local url = get_url()
    local cmd = get_download_cmd(url)
    norns.system_cmd(cmd, callback)
end

local function get_decompress_cmd()
    local staging = Installer.STAGING_DIR
    local asset = get_asset_filename()
    return "tar -xf " .. staging .. asset .. " -C " .. staging
end

local function get_install_cmd()
    local staging_dir = Installer.STAGING_DIR .. "/" .. Installer.PLUGIN.NAME
    return "cp -R " .. staging_dir .. " " .. Installer.INSTALL_DIR
end

local function install_plugin()
    os.execute(get_decompress_cmd())
    os.execute(get_install_cmd())
end

local function file_exists(path)
    local f = io.open(path)
    if f == nil then
        return false
    end
    f:close()
    return true
end

local function get_manifest()
    local ext_base = Installer.INSTALL_DIR
    local name = Installer.PLUGIN.NAME
    local plugin_base = ext_base .. name .. "/" .. name .. "/"
    local class_base = plugin_base .. "Classes/"

    local plug = plugin_base .. "ByteBeat_scsynth.so"
    local ugen = class_base .. "ByteBeat.sc"
    local ctrl = class_base .. "ByteBeatController.sc"

    return {plug, ugen, ctrl}
end

local function check_manifest(manifest)
    for _, path in ipairs(manifest) do
        if not file_exists(path) then
            return false, path
        end
    end
    return true, nil
end

function Installer.init()
    local manifest = get_manifest()
    local installed, _ = check_manifest(manifest)
    state = installed and State.INSTALLED or State.NOT_INSTALLED
end

function Installer.is_installed()
    return state == State.INSTALLED
end

function Installer.is_working()
    return state ~= State.NOT_INSTALLED and state ~= State.INSTALLED
end

function Installer.install(options)
    state = State.DOWNLOADING
    download_plugin(function()
        if options.on_downloaded then
            options.on_downloaded()
        end
        state = State.INSTALLING
        install_plugin()
        if options.on_installed then
            options.on_installed()
        end
        state = State.SHUTTING_DOWN
    end)
end

return Installer
