wifi.setmode(wifi.STATION)
wifi.sta.config("ssid","password")
print(wifi.sta.getip())

pin_a_speed = 1
pin_a_dir = 3
pin_b_speed = 2
pin_b_dir = 4
FWD = gpio.HIGH
REV = gpio.LOW
duty = 1023
--initiate motor A
gpio.mode(pin_a_speed,gpio.OUTPUT)
gpio.write(pin_a_speed,gpio.LOW)
pwm.setup(pin_a_speed,1000,duty) --PWM 1KHz, Duty 1023
pwm.start(pin_a_speed)
pwm.setduty(pin_a_speed,0)
gpio.mode(pin_a_dir,gpio.OUTPUT)
--initiate motor B
gpio.mode(pin_b_speed,gpio.OUTPUT)
gpio.write(pin_b_speed,gpio.LOW)
pwm.setup(pin_b_speed,1000,duty) --PWM 1KHz, Duty 1023
pwm.start(pin_b_speed)
pwm.setduty(pin_b_speed,0)
gpio.mode(pin_b_dir,gpio.OUTPUT)

function motor(pin_speed, pin_dir, dir, speed)
    gpio.write(pin_dir,dir)
    pwm.setduty(pin_speed, (speed * duty) / 100)
end

function motor_a(dir, speed)
    motor(pin_a_speed, pin_a_dir, dir, speed)
end
    
function motor_b(dir, speed)
    motor(pin_b_speed, pin_b_dir, dir, speed)
end

motor_a(FWD, 0)
motor_b(FWD, 0)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
             motor_a(FWD, 100)
        elseif(_GET.pin == "OFF1")then
             motor_a(FWD, 0)
        elseif(_GET.pin == "ON2")then
              motor_b(FWD, 100)
        elseif(_GET.pin == "OFF2")then
             motor_b(FWD, 0)
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
