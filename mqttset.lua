do
    if not killtop then killtop = {} end
    if not dat then
        dat = {
            brk = 'iot.eclipse.org',
            port = 1883,
            clnt = 'nooliteMTRF'
        }
    end
    local brk = dat.brk
    dat.brk = nil
    local port = dat.port
    dat.port = nil
    local passw, user
    if dat.user then 
        user = dat.user
        dat.user = nil
    end

    if dat.passw then 
        passw = dat.user
        dat.passw = nil
    end
    user = user or dat.clnt
    passw = passw or 'passwd'

    local subscribe, merror, newm, mconnect
    
    function subscribe(con)
        print("connected")
        dat.broker = true
        con:subscribe(dat.clnt.."/com/#", 0)
        con:publish(dat.clnt..'/state', "ON", 0, 1)
        print("Subscribed")
    end
    
    function merror(con)
        con = nil
        m = nil
        tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() mconnect(newm()) end)
    end
    
    function newm()
        m = mqtt.Client(dat.clnt, 25, user, passw)
        m:lwt(dat.clnt..'/state', "OFF", 0, 1)
        m:on("offline", function(con)
            con:close()
            dat.broker = false
            print("offline")
            merror(con)
        end)

        m:on("message", function(con, top, dt)
            killtop[1] = tonumber(string.match(top, "/(%w+)$")) or 65
            if killtop[1] ~= 65 then 
                killtop[2], killtop[3] =  string.match(dt, '{"(%w+)":"?(%w+)"?}') 
                print('MQTT Got:', killtop[1], killtop[2], killtop[3])
                dofile('run.lua')
            end
        end)
        return m
    end
    function mconnect(con)
        con:connect(brk, port, 0, 0, subscribe, merror)
    end
    mconnect(newm())
end
