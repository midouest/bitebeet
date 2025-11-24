local Installer = include('lib/install')

local InstallCtrl = {}

local install_messages = {}

local function handle_downloaded()
    table.insert(install_messages, 'Downloaded!')
    table.insert(install_messages, 'Installing...')
end

local function handle_installed()
    table.insert(install_messages, 'Installed!')
    table.insert(install_messages, 'Shutting down...')
    table.insert(install_messages, 'Please reboot.')
    local shutdown = metro.init()
    shutdown.event = function()
        norns.shutdown()
    end
    shutdown:start(1 / 15.0, 1)
end

local function handle_failed(reason)
    if reason == "download" then
        table.insert(install_messages, "Download failed.")
    elseif reason == "install" then
        table.insert(install_messages, "Install failed.")
    end
end

function InstallCtrl.install()
    if Installer.is_working() then
        return
    end
    table.insert(install_messages, 'Downloading...')
    Installer.install {
        on_downloaded = handle_downloaded,
        on_installed = handle_installed,
        on_failed = handle_failed,
    }
end

function InstallCtrl.redraw()
    if #install_messages > 0 then
        local len = #install_messages
        for i, msg in ipairs(install_messages) do
            screen.level(math.max(1, 15 - 3 * (len - i)))
            screen.move(0, i * 8)
            screen.text(msg)
        end
    else
        screen.level(15)
        screen.move(0, 8)
        screen.text('ByteBeat SuperCollider plugin')
        screen.move(0, 16)
        screen.text('is not installed.')
        screen.move(0, 32)
        if not Installer.can_install() then
            screen.text('Internet connection required.')
        else
            screen.text('Press any K2/K3 to install...')
        end
    end
end

return InstallCtrl
