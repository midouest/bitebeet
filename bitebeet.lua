-- BITEBEET
Installer = include('lib/install')
InstallCtrl = include('lib/installctrl')
StringUtil = include('lib/stringutil')

-- Engine is loaded dynamically if UGen files are detected
engine.name = nil

local redraw_metro = nil
local cursor = 0
local buffer = {
    "((t<<1)^((t<<1)+(t>>7)&t>>12))|t>>(",
    "4-(1^7&(t>>19)))|t>>7"
}

local function load_engine()
    engine.load("ByteBeat", function()
        engine.register_commands(
            {{"expr", "si"}, {"amp", "f"}, {"restart", ""}}, 3)
        engine.expr(table.concat(buffer, ""), 0)
        engine.amp(0.1)
    end)
end

function init()
    Installer.init()

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
    buffer = StringUtil.insert(buffer, cursor, char)
    cursor = cursor + 1
end

function keyboard.code(code, value)
    if value == 0 then
        return
    end

    if code == "BACKSPACE" and cursor > 0 then
        buffer = StringUtil.delete(buffer, cursor)
        cursor = cursor - 1
    elseif code == "ENTER" then
        engine.expr(table.concat(buffer))
    end
end

function redraw()
    screen.clear()

    if not Installer.is_installed() then
        InstallCtrl.redraw()
    else
        screen.font_face(1)
        screen.font_size(8)
        for i, line in ipairs(buffer) do
            screen.move(0, i * 8)
            screen.text(line)
        end
    end

    screen.update()
end