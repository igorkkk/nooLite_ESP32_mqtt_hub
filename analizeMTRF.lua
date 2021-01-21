do
local itm = gotRAW[5]
local com = gotRAW[6]
wth[itm] = '{"cell":'..itm..','

-- 0 - выключить нагрузку
if com == 0 then
	wth[itm] = wth[itm].. '"state":"Off"}'
-- 1 - понижение яркости, 2 - включить, 3 - повысить яркость,
-- 5 - изменить яркость в обратном направлении, 10 - остановить изменение яркости 
elseif com == 1 or com == 2 or com == 3 or com == 5 or com == 10  then	
	wth[itm] = wth[itm].. '"state":"On"}'
-- 4 - Переключает нагрузку
elseif com == 4 then
	wth[itm] = wth[itm]..'"state":"Chg"}'
-- 6 - Установить заданную в расширении команды яркость
elseif com == 6 then
    if gotRAW[8] == 0 then
		wth[itm] = wth[itm]..'"state":"Off"}'
    else
    	wth[itm] = wth[itm]..'"state":"On"}'
    end

-- 130 - Ответ от исполнительного устройства
elseif com == 130 then
    if gotRAW[10] == 0 then 
    	wth[itm] = wth[itm]..'"state":"Off"}'
    else
    	wth[itm] = wth[itm]..'"state":"On"}'
    end

-- 21 - Передает данные о температуре, влажности и состоянии элементов
elseif com == 21 then
    local temp = 0
    local hempH = gotRAW[9]
    local hempL = gotRAW[8]
    temp = bit.lshift(bit.band(hempH, 0x0F),8) + hempL
    if (temp > 0x7FF) then
        temp = temp - 0x1000
    end
    temp = temp * 0.1
    wth[itm] = wth[itm]..'"t":'..temp
    
    if gotRAW[10] ~= 0 then
		wth[itm] = wth[itm]..',"h":'..gotRAW[10]
	end
	wth[itm] = wth[itm]..'}'

-- 20 - У устройства разрядился элемент питания.
elseif com == 20 then
	wth[itm] = wth[itm]..'"bat":"LowBat"}'

-- 25 - Включить свет на заданное время.
elseif com == 25 then
	local tm = 0
	tm = gotRAW[8] * 5 * 1000
	if gotRAW[7] == 6 then
		tm = (bit.lshift(gotRAW[9], 8) + gotRAW[8]) * 5
		if tm > 6870947 then tm = 6870947 end 
	elseif gotRAW[7] == 5 then
		tm = gotRAW[8] * 5
	end
	wth[itm] = wth[itm].. '"state":"On","timerOff":'..tm..'}'
---[[
	if tm > 0 then
		print('Start Timer')
		if not stoptimers or not stoptimers[itm] then
			(dofile'dotimer.lua')(itm, tm)
		else
			stoptimers[itm]:stop()
			stoptimers[itm]:start()
			print('\nTimer restarted\n')
		end

	end
--]]
-- for PU-112 Для RGB
elseif com > 15 and com < 20  then
	wth[itm] = wth[itm]..'"state":"On","cmd":'..com..'}'
else
--	gotRAW = {}
--	startUART = false
--	return
wth[itm] = nil
end
gotRAW = {}
startUART = false
return (function() dofile('mqttpub.lua') end)()
end