local tm = time.epoch2cal(time.get()+3*60*60)
if tm.year == 1970 then return (function() print('Wrong time') end)() end
do
local tx = string.format("%04d.%02d.%02d %02d:%02d", tm.year, tm.mon, tm.day, tm.hour, tm.min)
m:publish(dat.clnt..'/boot', tx,0,1)
local ip = dat.ip
m:publish(dat.clnt..'/ip', ip,0,1)
print(dat.clnt..'/boot','at '..tx)
print('ip published', ip)
dat.boot,tm,a,b,tx, ip = nil
end