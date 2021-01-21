do --!!!
    uart.setup(2, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {tx = 17, rx = 16})
    uart.start(2)
    sendRAW = {171,2,0,0,0,0,0,0,0,0,0,0,0,0,0}

    ---------------------- Type F -------------------------
    --sendMT({171,2,0,0,0,15,0,0,0,0,0,0,0,0,0})    -- Привязка к ячейке 0

    --sendMT({171,2,0,0,0,0,0,0,0,0,0,0,0,0,0})     -- Выключить
    --sendMT({171,2,0,0,0,2,0,0,0,0,0,0,0,0,0})     -- Включить
    --sendMT({171,2,0,0,0,25,5,2,0,0,0,0,0,0,0})    -- Включить на 2х5=10 секунд

    --sendMT({171,2,0,0,0,128,0,0,0,0,0,0,0,0,0})   -- Состояние

    --sendMT({171,2,0,0,0,129,16,2,0,2,0,0,0,0,0})  -- режим Яркости
    --sendMT({171,2,0,0,0,129,16,0,0,2,0,0,0,0,0})  -- режим Релейный
    --sendMT({171,2,0,0,0,129,16,0,0,255,0,0,0,0,0})-- режим - Сброс настроек

    --sendMT({171,2,0,0,0,6,1,55,0,0,0,0,0,0,0})    -- Установить Яркость

    -- Сервис для отвязки, нужны две команды:
    --sendMT({171,2,0,0,0,131,0,1,0,0,0,0,0,0,0})   -- Устройство в сервисный режим
    --sendMT({171,2,0,0,0,9,0,0,0,0,0,0,0,0,0})     -- Отвязка (устройство в сервисном режиме)


    --------------------Old Type Switch -------------------

    --sendMT({171,0,0,0,1,15,0,0,0,0,0,0,0,0,0})    -- Привязка к ячейке 1
    --sendMT({171,0,0,0,1,0,0,0,0,0,0,0,0,0,0})     -- Выключить
    --sendMT({171,0,0,0,1,2,0,0,0,0,0,0,0,0,0})     -- Включить


    ----------------- Pult -------------------------------
    --sendMT({171,1,3,0,2,15,0,0,0,0,0,0,0,0,0})    -- Привязка пульта к ячейке 2 
    --sendMT({171,1,5,0,2,9,0,0,0,0,0,0,0,0,0})     -- Очистка ячейки 2 от привязке к пульту

    gotRAW = {}
    -- counter = 1
    startUART = false

    function ptrANSW()
        local crc = 0
        for i = 1, 15 do crc = crc  + gotRAW[i] end 
        crc = bit.band(crc, 0xFF) 
        
        if crc ~= gotRAW[16] then print('Bad CRC'); return end
        local rawd = ""
        local kk = ''
        for k, v in pairs(gotRAW) do
            if k > 1 and k < 16 and k ~= 4 then 
                if k == 2 then kk = k..'-MOD'
                elseif k == 3 then kk = k..'-CTR'
                elseif k == 5 then kk = k..'-CHN'
                elseif k == 6 then kk = k..'-CMD'
                elseif k == 7 then kk = k..'-FMT'
                else kk = k end
                rawd = rawd..kk..":"..v.." " 
            end
            if k == 7 or k == 11 then rawd = rawd..'- ' end
        end
        print('Got: '..rawd)
        gotRAW = {}
        startUART = false
    end

    function sendMT(tbl)
        if tbl and type(tbl) == 'table' then sendRAW = tbl end
        if #sendRAW == 15 then
            local cr = 0
            for i = 1, 15 do cr = cr + sendRAW[i] end
            cr = bit.band(cr, 0xFF)
            sendRAW[16] = cr
            sendRAW[17] = 172
            local z = ""
            for k, v in pairs(sendRAW) do
                z = z.."; "..string.format("%02d", k).."=>"..v
            end
            for i=1,17 do uart.write(2, sendRAW[i]) end
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
    function bind(format, bind, cell)
        sendRAW = {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        if format == 'F' then sendRAW[2] = 2
        elseif format == 'Old' then sendRAW[2] = 0
        elseif format == 'Switch' then sendRAW[2] = 1; sendRAW[3] = 3       
        else print('Bad Format!'); return end

        if bind == 'On' then sendRAW[6] = 15
        elseif bind == 'Off' then sendRAW[6] = 9
        else print('Bad Bind'); return end

        if format == 'Switch' and bind ==  'Off' then
            sendRAW[3] = 5
        end 

        if type(cell) == 'number' and cell >= 0 and cell < 64 then sendRAW[5] = cell
        else print('Bad Cell'); return end
        sendMT()     
    end
    print('\n\n\nFUNCTION:\n\tbind(format, bind, cell)')
    print('USE:\n\tformat = "F", "Old", "Switch"')
    print('\tbind = "On", "Off"')
    print('\tcell = 0...63')



    function setRegeime(regeime, cell)
        -- sendMT({171,2,0,0,0,129,16,0,0,2,0,0,0,0,0})  -- режим Релейный
    --sendMT(     {171,2,0,0,0,129,16,2,0,2,0,0,0,0,0})  -- режим Яркости
        sendRAW = {171,2,0,0,0,129,16,0,0,2,0,0,0,0,0}
        if regeime == 'Relay' then sendRAW[8] = 0
        elseif regeime == 'Bright' then sendRAW[8] = 2
        else print('Bad Regeime!'); return end
        
        if type(cell) == 'number' and cell >= 0 and cell < 64 then sendRAW[5] = cell
        else print('Bad Cell'); return end
        sendMT()     
    end
    print('\n\nFUNCTION:\n\tsetRegeime(regeime, cell) -- For "F" switch only!')
    print('USE:\n\tregeime = "Relay", "Bright"')
    print('\tcell = 0...63')
    print('\nMTRF Ready!')

    function switch(format, act, cell)
        sendRAW = {171,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        if format == 'F' then sendRAW[2] = 2
        elseif format == 'Old' then sendRAW[2] = 0
        else print('Bad Format!'); return end

        if act == 'On' then sendRAW[6] = 2
        elseif act == 'Off' then sendRAW[6] = 0
        else print('Bad Bind'); return end
        
        if type(cell) == 'number' and cell >= 0 and cell < 64 then sendRAW[5] = cell
        else print('Bad Cell'); return end
        sendMT()     
    end
    print('\n\nFUNCTION:\n\tswitch(format, act, cell)')
    print('USE:\n\tformat = "F", "Old"')
    print('\tact = "On", "Off"')
    print('\tcell = 0...63')
    print('\nMTRF Ready!')





end