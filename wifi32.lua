do
dat = {}
wifi.start()
wifi.mode(wifi.STATION, true)
wifi.sta.on("disconnected", function(ev, info)
  print("Lost WiFi!")
  dat.wifi = false
  dat.ip = nil
end)
wifi.sta.on("got_ip", function(ev, info)
  dat.wifi = true
  dat.ip = info.ip
  print("NodeMCU Got IP:", info.ip)
end)
time.settimezone('EST-3')
time.initntp()

local scfg = {}
scfg.auto = true
scfg.save = true
scfg.ssid = 'MySSID'
scfg.pwd = 'MySuperPassword'
wifi.sta.config(scfg, true)
wifi.sta.connect()
end