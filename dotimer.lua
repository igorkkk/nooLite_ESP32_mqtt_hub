-- dotimer
if not wth then wth = {} end
if not stoptimers then stoptimers = {} end
local itm
local call = function(t) 
	t:stop()
	t:unregister()
	t = nil
	stoptimers[itm] = nil
	wth[itm] = '{"cell":'..itm..',"state":"Off"}'
	print('Timer '..itm..' Killed!')
	itm = nil
	if #stoptimers == 0 then stoptimers = nil end
	return (function() dofile('mqttpub.lua') end)()
end

return function(it, tm)
	itm = it
	stoptimers[itm] = tmr.create()
	stoptimers[itm]:register(tm*1000, tmr.ALARM_SEMI, call)
	stoptimers[itm]:start()
	print('\nTimer '..itm..' Started\n')
end