dat = {}
wifi.start()
wifi.sta.on("disconnected", function(ev, info)
  print("Lost WiFi!")
  dat.wifi = nil
   dat.ip = nil
end)
wifi.sta.on("got_ip", function(ev, info)
  dat.wifi = true
  dat.ip = info.ip
  print("NodeMCU Got IP:", info.ip)
end)
dofile('_setuser.lua')

time.settimezone(timezone)
time.initntp()
timezone = nil

local runfile = "setglobals.lua"
print("Try Run ", runfile)
tmr.create():alarm(5000, 0, function()
	if runfile and file.exists(runfile) then
		dofile(runfile)
	else
		print("No runfile! Start IDE")
		if file.exists('ide.lua') then
			rtcmem.write32(0, 501)
			node.restart()
		else
			print('Stop, No IDE!')
		end
	end
end)
