import json
import mqtt


#max temp of boiler water
var maxTemp=80
#allow the water to cool down to histTemp
var histTemp=70



var Volt_line=252
var Volt_hist_up=0.5
var Volt_hist_down=1

var pwm_inc=4
var pwm_dec=1


#mqtt topics
var m0= "stat/sensor/Balancer253V/Temperature"
var m00="stat/sensor/Balancer253V/Status"


var m1= "stat/sensor/Balancer253V/L1_Volt"
var m11="stat/sensor/Balancer253V/L1_PWM"
var m111="stat/sensor/Balancer253V/L1_Power"

var m2= "stat/sensor/Balancer253V/L2_Volt"
var m22="stat/sensor/Balancer253V/L2_PWM"
var m222="stat/sensor/Balancer253V/L2_Power"

var m3= "stat/sensor/Balancer253V/L3_Volt"
var m33="stat/sensor/Balancer253V/L3_PWM"
var m333="stat/sensor/Balancer253V/L3_Power"



var addPWM1=0
var addPWM2=0
var addPWM3=0

var val=0
var Volt1=0
var Volt2=0
var Volt3=0

var pwm1=0
var pwm2=0
var pwm3=0

var chan1=0
var chan2=0
var chan3=0

var myidx=0

var temperature=0
var wait=0
var doit=1
var doitA=1
var doitB=1
var doitC=1

var AUTOMATIC=1
var err=0

var now = 0
var old = 0 
var diff = 0

var hist_H=0
var hist_L=0


mqtt.publish(m00, "Initialisation ok")

def powerOFF()
print("Shutting down")
#set.power has different indexing
	gpio.set_pwm(27, 0)
	gpio.set_pwm(14, 0)
	gpio.set_pwm(12, 0)
	tasmota.cmd("Channel4 0")
	tasmota.cmd("Channel5 0")
	tasmota.cmd("Channel6 0")   
 	tasmota.set_power(0,false)
	tasmota.set_power(1,false)
	tasmota.set_power(2,false)
 	tasmota.set_power(3,false)
        tasmota.set_power(4,false)
        tasmota.set_power(5,false)
        pwm1=0
        pwm2=0
        pwm3=0
        AUTOMATIC=0

end

def enableAUTO()
print("Auto mode")
        AUTOMATIC=1
end

def enableAUTOMATIC()
print("AUTOMATIC=1")
        AUTOMATIC=1
end

def disableAUTOMATIC()
print("AUTOMATIC=0")
        AUTOMATIC=0
end


tasmota.remove_rule("Power1#state=0")
tasmota.add_rule("Power1#state=0", powerOFF)
tasmota.remove_rule("Power1#state=1")
tasmota.add_rule("Power1#state=1", enableAUTO)

tasmota.remove_rule("Power2#state=0")
tasmota.add_rule("Power2#state=0", disableAUTOMATIC)
tasmota.remove_rule("Power2#state=1")
tasmota.add_rule("Power2#state=1", enableAUTOMATIC)




######## ReadTemp() every 10s ############
def ReadTemp()
var sensors = json.load(tasmota.read_sensors())  

if sensors.contains('DS18B20')
temperature = (sensors['DS18B20']['Temperature'])
	if (temperature<0) || (temperature>maxTemp+10)
	temperature=666
	#sensor available but wrong reading
	end

	if (temperature>0) && (temperature<maxTemp+5)
        err=0
        mqtt.publish(m00, "Ok")

        #temperature reading ok, reset err
	end
else
	temperature=333
        err=err+1
        print("err= ")
        print(err)
        mqtt.publish(m00, "Err")

	if (err==10)
	#powerOFF()
        doit=0 
        wait=1
        mqtt.publish(m00, "Shutting down due err>=10")

	#sensor missing
	end
end

if (temperature!=333) && (temperature!=666) && (temperature>maxTemp) && (wait==0)
doit=0
wait=1
mqtt.publish(m00, "Temperature high, cooling down, Wait=1")
end


#heater/ssr stuck in heat ON mode 
#ssr sie zjebal i grzeje; wylacz stycznik grzalki
if (temperature!=333) && (temperature!=666) && (temperature>maxTemp+2)
	tasmota.set_power(2,false)
mqtt.publish(m00, "Temperature high, SSR failure, OUTPUT OFF")
end

if (temperature<histTemp) && (wait==1)
doit=1
wait=0
mqtt.publish(m00, "Temperature ok, reasuming heating, Wait=0")

end
if temperature==666
powerOFF()
doit=0
mqtt.publish(m00, "E666")
end
if temperature==333
#powerOFF()
mqtt.publish(m00, "E333")
end

print("Temperature: ", temperature," doit= ",doit," wait= ",wait, " err= ",err)
mqtt.publish(m0, str(temperature))
end
tasmota.add_cron("*/10 * * * * *", ReadTemp, "every_10_s")
#########################


class my_driver

	def init()
	hist_H=Volt_line+Volt_hist_up
	hist_L=Volt_line-Volt_hist_down
	end

def every_second()
mqtt.publish(m1, str(Volt1))
mqtt.publish(m2, str(Volt2))
mqtt.publish(m3, str(Volt3))
mqtt.publish(m11, str(pwm1))
mqtt.publish(m22, str(pwm2))
mqtt.publish(m33, str(pwm3))
#print("delay:", diff)


#when temp too high then wait=1
#so decrease pwms to zero

if (wait==1) || (AUTOMATIC==0)
	if (pwm1>0)
	pwm1=pwm1-50
                if pwm1<0
		pwm1=0
		end
        gpio.set_pwm(27, pwm1)
	end

	if (pwm2>0)
	pwm2=pwm2-50
                if pwm2<0
		pwm2=0
		end
        gpio.set_pwm(14, pwm2)
	end

	if (pwm3>0)
	pwm3=pwm3-50
                if pwm3<0
		pwm3=0
		end
        gpio.set_pwm(12, pwm3)
	end	      	
	
end

end

#def every_100ms()	
#end


def fast_loop()


var sensors = json.load(tasmota.read_sensors())
var Volts = (sensors['ENERGY']['Voltage'])
Volt1 = Volts[0]
Volt2 = Volts[1]
Volt3 = Volts[2]


	if (doit==1) && (wait==0) && (AUTOMATIC==1)    

                if Volt1>hist_H
			addPWM1=1
		end


                if Volt1<hist_L
			addPWM1=0
		end

                if (Volt1<hist_H) && (Volt1>hist_L) 
                        addPWM1=2
                end
       	 	
#################################################
                if Volt2>hist_H
			addPWM2=1
		end


                if Volt2<hist_L
			addPWM2=0
		end

                if (Volt2<hist_H) && (Volt2>hist_L) 
                        addPWM2=2
                end

#################################################
                if Volt3>hist_H
			addPWM3=1
		end


                if Volt3<hist_L
			addPWM3=0
		end

                if (Volt3<hist_H) && (Volt3>hist_L) 
                        addPWM3=2
                end

###############################################
                if addPWM1==1
 	        pwm1=pwm1+pwm_inc
	        end

	        if addPWM1==0
 	        pwm1=pwm1-pwm_dec
	        end

		if pwm1>1023
		pwm1=1023
		end
		if pwm1<0
		pwm1=0
		end
###############################################
                if addPWM2==1
 	        pwm2=pwm2+pwm_inc
	        end

	        if addPWM2==0
 	        pwm2=pwm2-pwm_dec
	        end

		if pwm2>1023
		pwm2=1023
		end
		if pwm2<0
		pwm2=0
		end
###############################################
                if addPWM3==1
 	        pwm3=pwm3+pwm_inc
	        end

	        if addPWM3==0
 	        pwm3=pwm3-pwm_dec
	        end

		if pwm3>1023
		pwm3=1023
		end
		if pwm3<0
		pwm3=0
		end

        	gpio.set_pwm(27, pwm1)
        	gpio.set_pwm(14, pwm2)
        	gpio.set_pwm(12, pwm3)
		#print(Volt1, Volt_line, Volt_max)
                #now=tasmota.millis()
                #diff=now-old
                #old=now
		
	end

end


end
tasmota.add_driver(my_driver())                     
tasmota.add_fast_loop(/-> my_driver.fast_loop()) 

