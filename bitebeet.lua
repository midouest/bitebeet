-- BITEBEET
-- low-rez live coding
-- v0.0.1 @midouest
--
-- KEYBOARD REQUIRED
--
-- GUIDE
-- This script is a bytebeat
-- interpreter. Bytebeats are
-- simple mathematical
-- expressions used to generate
-- glitchy, rhythmic melodies.
--
-- CONTROLS
-- ENTER: evaluate expression
-- ESC: reset t variable to 0
-- BACKSPACE: delete previous
-- ARROW KEYS: navigation
--
-- SYNTAX
-- The interpreter supports a
-- subset of the expression
-- syntax for the C programming
-- language.
--
-- one variable, t
-- - increments after each
--   sample at 8khz
--
-- constants
-- - integers (+/-)
-- - strings
--
-- math operators
-- () + - * / %
--
-- bitwise operators
-- & | ^ << >> ~
--
-- relational operators
-- < > <= >= == != !
--
-- ternary if-else
-- ?:
--
-- array subscript
-- []

Installer = include('lib/install')
InstallCtrl = include('lib/installctrl')
Editor = include('lib/editor')

-- Engine is loaded dynamically if UGen files are detected
engine.name = nil

local editor = nil

local COMMANDS = {
    { 'eval',  'si' },
    { 'amp',   'f' },
    { 'reset', '' }
}

local function load_engine()
    engine.load(
        'ByteBeat',
        function()
            engine.register_commands(COMMANDS, #COMMANDS)
            engine.eval(editor:get_buffer(), 1)
            engine.amp(0.1)
        end
    )
end

function init()
    Installer.init()

    editor = Editor.new()

    params:add_separator('bitebeet')

    params:add {
        type = 'text',
        id = 'expression',
        name = 'expression',
        text = 't&t>>4',
        action = function(val)
            editor:set_buffer(val)
        end
    }
    params:bang()

    if Installer.is_installed() then
        load_engine()
    end

    clock.run(
        function()
            while true do
                redraw()
                clock.sleep(1 / 15.0)
            end
        end
    )
end

function cleanup()
end

function key(n, z)
    if n ~= 1 and z == 1 and not Installer.is_installed() and Installer.can_install() then
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
