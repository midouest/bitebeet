local Installer = include('lib/install')

local InstallCtrl = {}

local needs_reboot = false
local install_messages = {}

local function handle_downloaded()
    table.insert(install_messages, "Downloaded!")
    table.insert(install_messages, "Installing...")
end

local function handle_installed()
    table.insert(install_messages, "Installed!")
    table.insert(install_messages, "Shutting down...")
    table.insert(install_messages, "Please reboot.")
    local shutdown = metro.init()
    needs_reboot = true
    shutdown.event = function() norns.shutdown() end
    shutdown:start(1 / 15.0, 1)
end

function InstallCtrl.install()
    if Installer.is_working() then return end
    table.insert(install_messages, "Downloading...")
    Installer.install {
        on_downloaded = handle_downloaded,
        on_installed = handle_installed
    }
end

function InstallCtrl.redraw()
    if #install_messages > 0 then
        screen.level(needs_reboot and 1 or 15)
        for i, msg in ipairs(install_messages) do
            screen.move(0, i * 8)
            screen.text(msg)
        end
    else
        screen.level(15)
        screen.move(0, 8)
        screen.text("ByteBeat SuperCollider plugin")
        screen.move(0, 16)
        screen.text("is not installed.")
        screen.move(0, 32)
        screen.text("Press any button to install...")
    end
end

return InstallCtrl
