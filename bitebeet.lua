-- BITEBEET
Installer = include('lib/install')
InstallCtrl = include('lib/installctrl')
Editor = include('lib/editor')

-- Engine is loaded dynamically if UGen files are detected
engine.name = nil

local redraw_metro = nil
local editor = nil

local COMMANDS = {
    {"eval", "s"},
    {"amp", "f"},
}

local function load_engine()
    engine.load("ByteBeat", function()
        engine.register_commands(COMMANDS, #COMMANDS)
        engine.eval(editor:get_buffer(), 0)
        engine.amp(0.1)
    end)
end

function init()
    Installer.init()

    editor = Editor.new {
        "((t<<1)^((t<<1)+",
        "(t>>7)&t>>12))|t",
        ">>(4-(1^7&(t>>19)",
        "))|t>>7"
    }

    if Installer.is_installed() then
        load_engine()
    end

    redraw_metro = metro.init()
    redraw_metro.time = 1 / 15.0
    redraw_metro.event = function() redraw() end
    redraw_metro:start()
end

function cleanup()
end

function key(n, z)
    if z == 1 and not Installer.is_installed() then
        InstallCtrl.install()
    end
end

function enc(n, d)
end

function keyboard.char(char)
    editor:handle_char(char)
end

function keyboard.code(code, value)
    editor:handle_code(code, value)
end

function redraw()
    screen.clear()

    if not Installer.is_installed() then
        InstallCtrl.redraw()
    else
        editor:redraw()
    end

    screen.update()
end
