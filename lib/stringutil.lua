local StringUtil = {}

function StringUtil.insert(str, cursor, data)
    return str:sub(1, cursor) .. data .. str:sub(cursor + 1)
end

function StringUtil.delete(str, cursor)
    return str:sub(1, cursor - 1) .. str:sub(cursor)
end

return StringUtil
