################################################ BALANCER 253V by MM ###############################
# Thanks to Sfromis for help

import json
import mqtt

################################################# settings: ########################################

# max temp of boiler water
var maxTemp=80

# allow the water to cool down to histTemp
var histTemp=70


# select the range when the heaters will start/stop to work
# if you narrow the range too much you will use less Energy for heater 
# but Voltage will become unstable
# Volt_line is the base line of the range
# Volt_hist_up - is the Voltage above Volt_line
# Volt_hist_down - is the Voltage belowe Volt_line
# 252.5 - upper limit
# 252   - Volt_line
# 250.5 - lower limit
# see graphic for explanation

var Volt_hist_up=0.5
var Volt_line=252
var Volt_hist_down=1.5

#how fast PWM is increased in fast_loop 3 or 4 is ok
var pwm_inc=3
var pwm_dec=1

# set Latitude and Longitude for proper Sunrise and Sunset
# device will on be ON in daylight
# Lat=50 Lon=20 is near Kraków, Poland
var Lat=50
var Lon=20

# if you use mqtt 
# don't forget to settup mqtt broker in tasmota config
var useMQTT=1

###################################################################################################

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

var Volt1=0
var Volt2=0
var Volt3=0

var pwm1=0
var pwm2=0
var pwm3=0

var temperature=0
var wait=0
var doit=1

var AUTOMATIC=0
var err=0

var hist_H=0
var hist_L=0


#AUTOMATIC buton is off at startup
tasmota.set_power(1,false)


#timers needs a delay until system boot is finished
def waitUntil()

	#setting up Latitude and Longitude
	tasmota.cmd(f"Backlog Latitude {Lat}; Longitude {Lon}")
	#enable logging after sunrise and disable after sunset
	tasmota.cmd('Timers ON');
	tasmota.cmd('Timer1 {"Enable":1,"Mode":1,"Time":"00:00","Window":0,"Days":"1111111","Repeat":1,"Output":2,"Action":1}')
	tasmota.cmd('Timer2 {"Enable":1,"Mode":2,"Time":"00:00","Window":0,"Days":"1111111","Repeat":1,"Output":2,"Action":0}')

	var nowT = tasmota.strftime('%H:%M',tasmota.rtc('local'))
	var timestatus = tasmota.cmd('Status 7')['StatusTIM']
	if (timestatus['Sunrise'] < nowT) && (timestatus['Sunset'] > nowT)
        	tasmota.set_power(1,true)
                AUTOMATIC=1
                print("Initialisation OK")
        	print('DAY')

                
                if useMQTT==1
	        mqtt.publish(m00, "Initialisation OK")
	        mqtt.publish(m00, "DAY")
                end
        else 
        	tasmota.set_power(1,false)
                AUTOMATIC=0
		print("Initialisation OK")
		print('NIGHT')

		if useMQTT==1
	        mqtt.publish(m00, "Initialisation OK")
	        mqtt.publish(m00, "NIGHT")
		end
	end

end

tasmota.remove_rule("System#Boot")
tasmota.add_rule("System#Boot", waitUntil)


def powerOFF()
print("SHUTTING DOWN: powerOFF")
	if useMQTT==1
	mqtt.publish(m00, "SHUTTING DOWN: powerOFF")
	end
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
print("enableAUTO")
        AUTOMATIC=1
	if useMQTT==1
	mqtt.publish(m00, "enableAUTO")
	end
end

def enableAUTOMATIC()
print("enableAUTOMATIC")
        AUTOMATIC=1
	if useMQTT==1
	mqtt.publish(m00, "enableAUTOMATIC")
	end
end

def disableAUTOMATIC()
print("disableAUTOMATIC")
        AUTOMATIC=0
	if useMQTT==1
	mqtt.publish(m00, "disableAUTOMATIC")
	end
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

        #temperature reading ok, reset err
	end
else
	temperature=333
        err=err+1
        print("Error 333 = {err=}")

	if useMQTT==1
        mqtt.publish(m00, "Error 333 = "+str(err))
	end

	if (err==10)
	#powerOFF()
        doit=0 
        wait=1
	
	print("Shutting down due error 333 >= 10")
	if useMQTT==1
        mqtt.publish(m00, "Shutting down due error 333 >= 10")
	end

	#sensor missing
	end
end

if (temperature!=333) && (temperature!=666) && (temperature>maxTemp) && (wait==0)
	doit=0
	wait=1

        print("Temperature high, cooling down, Wait=1")
	if useMQTT==1
	mqtt.publish(m00, "Temperature high, cooling down, Wait=1")
	end

end


#heater/ssr stuck in heat ON mode 
if (temperature!=333) && (temperature!=666) && (temperature>maxTemp+2)
	tasmota.set_power(2,false)
	print("Temperature high, SSR failure, OUTPUT OFF")
	if useMQTT==1
	mqtt.publish(m00, "Temperature high, SSR failure, OUTPUT OFF")
	end
end

if (temperature<histTemp) && (wait==1)
	doit=1
	wait=0
	print("Temperature ok, reasuming heating, Wait=0")
	if useMQTT==1
	mqtt.publish(m00, "Temperature ok, reasuming heating, Wait=0")
	end

end

if temperature==666
	powerOFF()
	doit=0
	print("Error 666")
	if useMQTT==1
	mqtt.publish(m00, "Error 666")
	end
end

if temperature==333
	#powerOFF()
        print("Error 333")
	if useMQTT==1
	mqtt.publish(m00, "Error 333")
	end
end

        print(f"Temperature: {temperature:%.1f} {doit=} {wait=} {err=}")

	if useMQTT==1
	mqtt.publish(m0, str(temperature))
	end
end
tasmota.add_cron("*/10 * * * * *", ReadTemp, "every_10_s")
#########################


class my_driver

	def init()
	hist_H=Volt_line+Volt_hist_up
	hist_L=Volt_line-Volt_hist_down
	end

def every_second()

if (AUTOMATIC==1)

	if useMQTT==1
	mqtt.publish(m1, str(Volt1))
	mqtt.publish(m2, str(Volt2))
	mqtt.publish(m3, str(Volt3))
	mqtt.publish(m11, str(pwm1))
	mqtt.publish(m22, str(pwm2))
	mqtt.publish(m33, str(pwm3))
	end

end

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
		
	end

end


end
tasmota.add_driver(my_driver())                     
tasmota.add_fast_loop(/-> my_driver.fast_loop()) 

