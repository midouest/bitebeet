StringUtil = include('lib/stringutil')

local Editor = {}
Editor.__index = Editor

local chars_per_line = 16
local function format_buffer(buffer)
    local num_lines = math.ceil(#buffer / chars_per_line)
    local lines = {}
    for i = 1, num_lines do
        local s = ((i - 1) * chars_per_line) + 1
        local e = s + chars_per_line
        local line = buffer:sub(s, e)
        table.insert(lines, line)
    end
    return lines
end

local function index_to_cursor(i)
    local row = i // chars_per_line + 1
    local col = (i % chars_per_line)
    return {row, col}
end

local function cursor_to_index(c)
    local row = c[1]
    local col = c[2]
    return ((row - 1) * chars_per_line) + col
end

function Editor.new(buffer)
    local e =
        setmetatable(
        {
            _buffer = nil,
            _formatted = nil,
            _index = nil,
            _cursor = nil,
            _blink = false,
            _frame = 0
        },
        Editor
    )
    e:set_buffer(buffer)
    return e
end

function Editor:set_buffer(buffer)
    buffer = buffer or ''
    local formatted = format_buffer(buffer)
    local index = #buffer
    local cursor = index_to_cursor(index)
    self._buffer = buffer
    self._formatted = formatted
    self._index = index
    self._cursor = cursor
end

function Editor:get_buffer()
    return self._buffer
end

function Editor:handle_char(char)
    self._buffer = StringUtil.insert(self._buffer, self._index, char)
    self._formatted = format_buffer(self._buffer)
    self._index = self._index + 1
    self._cursor = index_to_cursor(self._index)
end

function Editor:handle_code(code, value)
    if value == 0 then
        return
    end

    if code == 'BACKSPACE' and self._index > 0 then
        self._buffer = StringUtil.delete(self._buffer, self._index)
        self._formatted = format_buffer(self._buffer)
        self._index = self._index - 1
        self._cursor = index_to_cursor(self._index)
    elseif code == 'ENTER' then
        engine.eval(self._buffer, 0)
        params:set('expression', self._buffer, true)
    elseif code == 'ESC' then
        engine.reset()
    elseif code == 'UP' then
        self._index = util.clamp(self._index - chars_per_line, 0, #self._buffer)
        self._cursor = index_to_cursor(self._index)
    elseif code == 'DOWN' then
        self._index = util.clamp(self._index + chars_per_line, 0, #self._buffer)
        self._cursor = index_to_cursor(self._index)
    elseif code == 'LEFT' then
        self._index = util.clamp(self._index - 1, 0, #self._buffer)
        self._cursor = index_to_cursor(self._index)
    elseif code == 'RIGHT' then
        self._index = util.clamp(self._index + 1, 0, #self._buffer)
        self._cursor = index_to_cursor(self._index)
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
    for i, line in ipairs(self._formatted) do
        screen.move(0, i * 9)
        screen.text(line)
    end

    self._frame = self._frame + 1
    if self._frame % 3 == 0 then
        self._blink = not self._blink
    end
end

return Editor
