return function(itm, comm, arg)
    local pat = {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,172}
    itm = itm or killtop[1]
    comm = comm or killtop[2]
    arg = arg or killtop[3]
    
    print('\nSet Bright '..arg..' At Cell '..itm..'!\n')

    if comm == 'brgtf' then pat[2] = 2 end 
    arg = tonumber(arg) or arg
    local map = function(s)
        if  s <= 0 then return s end
        local d = 35 + s*120/100
        return math.floor(d)
    end
    pat[5] = itm
    local dd = tonumber(arg) or 100
    if dd > 100 then dd = 100 end
    pat[6] = 6
    pat[7] = 1
    pat[8] = map(dd)
    local crc = 0
    for i = 1, 15 do crc = crc + pat[i] end
    pat[16] = bit.band(crc, 0xFF)
    pat[17] = 172

    local send = ''
    for i = 1, 17 do send = send..string.char(pat[i]) end
    uart.write(2, send)
    -- tmr.create():alarm(300, tmr.ALARM_SINGLE, function(t) 
    --     t:stop()
    --     t:unregister()
    --     t = nil
    --     uart.write(2, send)
    --     send = nil 
    -- end)
end