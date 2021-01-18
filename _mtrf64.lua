M = {}
M.RAW = {}
local tmrkill
local pointer = 1
local ustart = false
local function stopUART()
	ustart = false
end
tmrkill = tmr.create()
tmrkill:register(1000, tmr.ALARM_SEMI, function()
	ustart = false
	M.RAW = {}
end)

M.check = function()
	tmrkill:stop()
	print('length = ', #M.RAW)
	--table.foreach(M.RAW, print)
	if #M.RAW == 17 then 
		local sum = 0
		for i = 1, 15 do sum = sum + M.RAW[i] end
		sum = 256 - bit.band(255, sum)
		print("Sum = ", sum, ' End = ', M.RAW[16] )
		if M.RAW[16] == sum then
			if M.call then M.call() end
		end
	end
end

M.setMTRF = function(tbl, call)
	M.tbl = tbl
	if call then M.call = call end
	uart.on(2, "data",1,
	    function(data)
	    	if ustart == false and string.byte(data, 1) ~= 171	then 
	    		return
	    	elseif ustart == false then 
	    		pointer = 1
	    		tmrkill:start()
	    		ustart = true
	    	end
	    	M.RAW[pointer] = string.byte(data, 1)
	    	if #M.RAW == 17 then M.check() else pointer = pointer + 1 end
	    end, 0)
end
return M