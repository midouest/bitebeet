-- bitebeet
Installer = include('lib/install')
InstallCtrl = include('lib/installctrl')

-- Engine is loaded dynamically if UGen files are detected
engine.name = nil

local redraw_metro = nil

local function load_engine()
    engine.load("ByteBeat", function()
        engine.register_commands(
            {{"expr", "si"}, {"amp", "f"}, {"restart", ""}}, 3)
        engine.expr("((t<<1)^((t<<1)+(t>>7)&t>>12))|t>>(4-(1^7&(t>>19)))|t>>7",
                    0)
        engine.amp(0.1)
    end)
end

function init()
    Installer.init()

    if Installer.is_installed() then load_engine() end

    redraw_metro = metro.init()
    redraw_metro.time = 1 / 15.0
    redraw_metro.event = function() redraw() end
    redraw_metro:start()
end

function cleanup() end

function key(n, z)
    if z == 1 and not Installer.is_installed() then InstallCtrl.install() end
end

function enc(n, d) end

function redraw()
    screen.clear()

    if not Installer.is_installed() then InstallCtrl.redraw() end

    screen.update()
end
