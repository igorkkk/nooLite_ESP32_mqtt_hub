if risetimers and risetimers[itm] then print('Rise Running Now!'); return end 
if not wth then wth = {} end
if not risetimers then risetimers = {} end
local itm
local comm = 'brgt'
local brgt = 10
local delta = 2
local trgt = 100

local exit = function()
	itm, comm, brgt, delta, trgt = nil, nil, nil, nil, nil
	if #risetimers == 0 then risetimers = nil end
	return (function() dofile('mqttpub.lua') end)()
end

local call = function(t) 
	if brgt >= trgt or dat.stoprise == itm then
		dat.stoprise = nil
		t:stop()
		t:unregister()
		t = nil
		risetimers[itm] = nil
		if #risetimers == 0 then risetimers = nil end
		wth[itm] = '{"cell":'..itm..',"state":"Off"}'
		print('Timer '..itm..' Killed!')
	else
		brgt = brgt + delta
		if brgt > 75 then brgt = 100 end
		dofile('brgt.lua')(itm, comm, brgt)
		print('Set Cell '.. itm..' at Bright '.. brgt)
	end
end

return function(it, cmd, tm)
	itm = it or killtop[1]
	cmd = cmd or killtop[2]
	tm = tm or killtop[3]
	tm = tonumber(tm) or 0
	if tm < 3 or tm > 20 then print('Bad Rise Time'); return exit() end 
	if risetimers[itm] then print('Rise Ranning Now!'); return exit() end 
	if cmd == 'risef' then comm = 'brgtf' end

	tm = math.floor((tm * 60 ) / 37)
	print("\nStep Time at Rise: "..tm.." Sec.")
	risetimers[itm] = tmr.create()
	risetimers[itm]:register(tm*1000, tmr.ALARM_AUTO, call)
	risetimers[itm]:start()
	print('\nTimer '..itm..' Started\n')
end