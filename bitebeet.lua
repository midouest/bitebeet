-- bitebeet
engine.name = "ByteBeat"

function init()
    engine.expr("((t<<1)^((t<<1)+(t>>7)&t>>12))|t>>(4-(1^7&(t>>19)))|t>>7", 0)
    engine.amp(0.1)
end
