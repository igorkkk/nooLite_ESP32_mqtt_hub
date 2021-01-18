gotRAW = {}
--counter = 1
startUART = false

local function ptrANSW()
    local crc = 0
    for i = 1, 15 do crc = crc  + gotRAW[i] end 
    crc = bit.band(crc, 0xFF) 
    
    if crc ~= gotRAW[16] then print('Bad CRC'); return end
    local rawd = ""
    local kk = ''
    for k, v in pairs(gotRAW) do
        if k > 1 and k < 16 and k ~= 4 then 
            if     k == 2 then kk = k..'/mod'
            elseif k == 3 then kk = k..'/ctr'
            elseif k == 5 then kk = k..'/chn'
            elseif k == 6 then kk = k..'/cmd'
            elseif k == 7 then kk = k..'/fmt'
            else kk = k end
            rawd = rawd..kk..":"..v.." " 
        end
        if k == 7 or k == 11 then rawd = rawd..'- ' end
    end
    print('Got: '..rawd)
    wth.raw = '{"cell":'..gotRAW[5]..',"raw":"'..rawd..'"}' 
    -- gotRAW = {}
    -- startUART = false
    dofile('analizeMTRF.lua')
end

uart.on(2,"data",1,
    function(data)
        local bt = string.byte(data, 1)
        if startUART == false and bt ~= 173 then return
        elseif startUART == false then startUART = true end
        gotRAW[#gotRAW+1] = bt
        if #gotRAW == 17 then ptrANSW() end
end, 0)
