--print('run!')
local killtop
if not dat.killcmdtb then 
    dat.killcmdtb = tmr.create()
    dat.killcmdtb:register(2000, tmr.ALARM_SEMI, function (t)
        if comtb and #comtb > 0 then 
            print('#comtb = '..#comtb..' run.lua starts')
            dofile'run.lua'
        else
            t:stop()
            t:unregister()
            t, dat.killcmdtb = nil, nil
            print('\t\t\ttable "ncmdtb" killed!')
        end
    end)
    dat.killcmdtb:start()
end

if comtb and #comtb > 0 then 
    dat.killcmdtb:stop()
    killtop = table.remove(comtb)
    dat.running = true
    dat.killcmdtb:start() 
else
    dat.running = false
    dat.killcmdtb:stop()
    dat.killcmdtb:unregister()
    dat.killcmdtb = nil
    return
end

local func = killtop[2]
if func == 'brgt' or func == 'brgtf' then 
    dofile('brgt.lua')(); return
elseif func == 'rise' or func == 'risef' then 
    if risetimers and risetimers[killtop[1]] then 
        print('Rise Ranning Now!'); return  
    else
        dofile('rise.lua')(); return
    end
end 
local pat = {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,172}
local itm, arg = killtop[1], killtop[3]
arg = tonumber(arg) or arg
pat[5] = itm

if func == "switch" or func == "switchf" then 
    if risetimers and risetimers[itm] then
       dat.stoprise = itm
       print('Rise At Cell '..itm..' Stopped!')
    end

    pat[2] = func == "switchf" and 2 or 0
    pat[6] = arg == "On" and 2 or 0

elseif func == "time" or func == "timef" then
    pat[2] = func == "timef" and 2 or 0
    pat[6] = 25
    local time = tonumber(arg) or 0
    if time < 5 then time = 5 end
    time = math.floor(time/5)
    if time < 256 then
        pat[7] = 5
        pat[8] = time
    else
        pat[7] = 6
        pat[8] = bit.band(time, 0xFF)
        pat[9] = bit.rshift(time, 8)
    end

elseif func == "askf" then
    pat[2] = 2
    pat[6] = 128

elseif func == "bind" or func == "bindf" then
    pat[2] = func == "bindf" and 2 or 0
    pat[6] = arg == "On" and 15 or 9
    
elseif func == "bindpult" then -- Привязка/отвязка к пультам и датчикам
    pat[2] = 1
    if arg == "On" then pat[6] = 15; pat[3] = 3
    else pat[6] = 9; pat[3] = 5 end

elseif func == "bindFtoPult" then -- Привязка/отвязка F к пультам
     if arg == "On" then
        pat[2] = 2; pat[6] = 131; pat[8] = 1 
    elseif arg == "Off" then
        pat[2] = 0; pat[6] = 9
    end
    table.foreach(pat,print)
elseif func == "relayf" then -- Режим реле/яркость
    pat = {171,2,0,0,0,129,16,0,0,2,0,0,0,0,0}
    pat[8] = arg == "On" and 0 or 2
end

local crc = 0
for i = 1, 15 do crc = crc + pat[i] end
pat[16] = bit.band(crc, 0xFF)
pat[17] = 172
for i=1,17 do uart.write(2, pat[i]) end