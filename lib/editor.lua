StringUtil = include('lib/stringutil')

local Editor = {}
Editor.__index = Editor

function Editor.new(buffer)
    buffer = buffer or {""}
    rows = #buffer
    cursor = {rows, #buffer[rows]}
    return setmetatable({
        _cursor = cursor,
        _buffer = buffer,
        _blink = false,
        _frame = 0,
    }, Editor)
end

function Editor:get_buffer()
    return table.concat(self._buffer, "")
end

function Editor:handle_char(char)
    local row = self._cursor[1]
    local col = self._cursor[2]
    self._buffer[row] = StringUtil.insert(self._buffer[row], col, char)
    self._cursor[2] = col + 1
end

function Editor:handle_code(code, value)
    if value == 0 then
        return
    end

    if code == "BACKSPACE" and cursor[2] > 0 then
        local row = self._cursor[1]
        local col = self._cursor[2]
        self._buffer[row] = StringUtil.delete(self._buffer[row], col)
        self._cursor[2] = col - 1
    elseif code == "ENTER" then
        engine.eval(table.concat(self._buffer), 0)
    elseif code == "UP" then
        self._cursor[1] = self._cursor[1] - 1
    elseif code == "DOWN" then
        self._cursor[1] = self._cursor[1] + 1
    elseif code == "LEFT" then
        self._cursor[2] = self._cursor[2] - 1
    elseif code == "RIGHT" then
        self._cursor[2] = self._cursor[2] + 1
    end
    --[[
        ESC, TAB, CAPSLOCK, LEFTSHIFT, LEFTCTRL, LEFTMETA, LEFTALT,
        RIGHTSHIFT, RIGHTCTRL, RIGHTALT, DELETE,
        F1-10
    ]]
end

function Editor:redraw()
    if self._blink then
        local row = self._cursor[1]
        local col = self._cursor[2]
        local x = col * 8
        local y = (row - 1) * 9

        screen.level(1)
        screen.rect(x, y, 8, 9)
        screen.fill()

        screen.move(x, y)
        screen.line_rel(0, 9)
        screen.level(15)
        screen.stroke()
    end

    screen.level(15)
    screen.font_face(67)
    screen.font_size(8)
    for i, line in ipairs(self._buffer) do
        screen.move(0, i * 9)
        screen.text(line)
    end

    self._frame = self._frame + 1
    if self._frame % 3 == 0 then
        self._blink = not self._blink
    end
end

return Editor
