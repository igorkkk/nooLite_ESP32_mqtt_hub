do
uart.setup(2, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {tx = 17, rx = 16})
uart.start(2)
sendRAW = {171,0,0,0,0,2,0,0,0,0,0,0,0,0,0}


crcR = 0
gotRAW = {}
counter = 0
moder = 0
switch = 2

startUART = false


function ptrANSW()
    local crc = 0
    for i = 1, 15 do crc = crc  + gotRAW[i] end 
    crc = bit.band(crc, 0xFF) 
    if crc ~= gotRAW[16] then print('Bad CRC'); return end
    print('Cell = '..gotRAW[5])

    if gotRAW[8] ~= 0 then
        local raw = ""
        local rawd = ""
        for k, v in pairs(gotRAW) do
            raw = raw..k..":"..string.format(" %02X", v).."; "
            rawd = rawd..k..":"..string.format("%03d",v).."; "
        end
        print(raw)
        print(rawd)
    end

    gotRAW = {}
    startUART = false
end

function sendMT()
    local cr = 0
    for i = 1, 15 do cr = cr + sendRAW[i] end
    cr = bit.band(cr, 0xFF)
    sendRAW[16] = cr
    sendRAW[17] = 172
    local z = ""
    for k, v in pairs(sendRAW) do
        -- z = z.." "..k..": 0x"..string.format("%02X", v)
        z = z.."; "..string.format("%02d", k).."=>"..v
    end
    --print('Send:')
    --print(z)
    for i=1,17 do
        uart.write(2, sendRAW[i])
    end
end

uart.on(2,"data",1,
    function(data)
        local bt = string.byte(data, 1)
        if startUART == false and bt ~= 173 then return
        elseif startUART == false then startUART = true end
        gotRAW[#gotRAW+1] = bt
        if #gotRAW == 17 then ptrANSW() end
end, 0)

tmr.create():alarm(3000, 1, function(t)
    if counter == 64 and moder == 0 then
        counter = 0
        moder = 2
        switch = 2
        sendRAW[2] = moder
    elseif counter == 64 and moder == 2 then
        t:stop()
        t:unregister()
        t = nil
        print('All Done!')
        return
    end
    --print('Ask cell '..counter)
    sendMT()
    if switch == 2 then
        switch = 0
    else
        counter = counter + 1
        switch = 2
    end
    sendRAW[6] = switch
    sendRAW[5] = counter
end)
end