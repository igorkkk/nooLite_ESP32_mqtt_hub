wth = {}
uart.setup(2, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {tx = 17, rx = 16})
uart.start(2)
print('Client:',dat.clnt)
dat.boot = true
--dofile'setglobfn.lua'
dofile'mqttset.lua'
dofile'main.lua'
