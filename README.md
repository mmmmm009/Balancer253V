# Balancer253V

PWM controller for a 3-phase heater solving the 253V problem. No soldering, to build from ready-made components. Based on ESP32 and tasmota

I am writing the description and diagram after the fact and something may be slightly wrong ;).

BOM:

ESP32
3x PZEM-004t
3x 0-3V to 4-20mA voltage to current converter
3x SSR 25A 4-20mA
DS18b20
DC-DC 12/5
DC-DC 12/12 as a stabilizer
Relay - optional
The system monitors the voltage on three phases (voltage measurement approximately every 200ms - pzem 004t). If the voltage is above the set threshold, the PWM increases the heater power until the voltage drops and falls within the selected range. If the voltage is within the selected range, the PWM remains unchanged. If the voltage drops below the lower limit of the range, the PWM will slowly reduce the heater power, etc. Due to the limitation of pzem004t (about 200ms per measurement), PWM changes are made between subsequent pzem measurements with a set step (about every 20ms, so "blindly"). The temperature sensor protects the system from boiling water ;) Due to interference, the sensor is sometimes invisible to the tasmota (this problem is solved by software).

Additionally, a relay that switches off the 3-phase contactor (right next to the heater) in the event of a failure.

The script was written in Berry Script, which is available "off the shelf" on every ESP32 tasmota, thanks to which we can easily change it. In addition, tasmota gives us the ability to send what we need via mqtt (e.g. to Home Assistant).

The system works and is in the testing/tuning phase. For now, tested for a few days. Result: energy production increased by 2x. Heater placed in a 200l boiler (the same one heated by the heat pump).

If this is useful to someone, someone modifies/improves the script, please share your knowledge :)

Both .be files should be uploaded to the tape using Tools/Manage file system on your tape's website.

Don't burn the house down ;)



Regulator PWM do grzałki 3 fazowej rozwiązujący problem 253V.
Bez lutowania, do zbudowania z gotowych elementów.
W oparciu o ESP32 i tasmota

Opis i schemat robię post factum i może się coś lekko nie zgadzać ;).


BOM:
1. ESP32
2. 3x PZEM-004t
3. 3x 0-3V na 4-20mA konwerter napięcie na prąd
4. 3x SSR 25A 4-20mA 
5. DS18b20
6. DC-DC 12/5
7. DC-DC 12/12 jako stabilizator
8. Przekaźnik - opcjonalnie

Układ monitoruje napięcie na trzech fazach (pomiar napięcia co około 200ms - pzem 004t).
Jeśli napięcie jest powyżej ustawionego progu, to PWM zwiększa moc grzałki, aż do momentu kiedy napięcie spadnie i będzie mieścić się w wybranym przedziale.
Jeśli napięcie mieści się w wybranym przedziale, to PWM zostaje bez zmian.
Jeśli napięcie spadnie poniżej dolnej granicy przedziału, to PWM będzie powoli zmniejszał moc grzałki itd....
Ze względu na ograniczenie pzem004t (około 200ms na pomiar), zmiany PWM dokonywane są pomiędzy kolejnymi pomiarami pzem'a z zadanym krokiem (co około 20ms, więc niejako "w ciemno").
Czujnik temperatury zabezpiecza układ przed zagotowaniem wody ;)
Ze względu na zakłócenia czujnik od czasu do czasu jest niewidoczny dla tasmoty (problem ten jest rozwiązany programowo).


Dodatkowo przekaźnik wyłączający stycznik 3 fazowy (tuż przy samej grzałce) w razie awarii.

Skrypt napisany został w Berry Script, który dostępny jest "od ręki" na każdej tasmocie ESP32, dzięki temu mamy możliwość łatwej jego zmiany.
Ponadto tasmota daje nam możliwość wysyłania tego co potrzebujemy po mqtt (np. do Home Assistanta).

Układ działa i jest w fazie testów/tuningu. Póki co, przetestowany kilka dni. Wynik: produkcja energii wzrosła 2x.
Grzałka umieszczona w bojlerze 200l (ten sam, który podgrzewa pompa ciepła).

Jeśli komuś się to przyda, ktoś zmodyfikuje/ulepszy skrypt, to niech proszę podzieli się wiedzą :)

Oba pliki .be należy wgrać na tasmotę przez Tools/Manage file system na stronie waszej tasmoty.

Nie spalcie chaupy ;)

![mqtt1](https://github.com/user-attachments/assets/0ad2a44d-125e-4e2e-94c8-ed0e1f2efd60)

   
![Solarman1](https://github.com/user-attachments/assets/3ee0d55f-0dc5-48f3-82a0-fca5075f27a0)

![Solarman2](https://github.com/user-attachments/assets/d086ebe6-192d-44be-9bd1-42ffae936477)


![BalancerBox2](https://github.com/user-attachments/assets/601542f6-aaf7-4eed-9b31-a82738832229)
![BalancerBox1](https://github.com/user-attachments/assets/eeb8b421-fe7e-4373-8c0d-0c67b1647204)

![pzem004t](https://github.com/user-attachments/assets/3bf7131c-a603-4d9c-95f8-cca1d57c64df)
![420mA](https://github.com/user-attachments/assets/c1df33d1-80e0-48d1-b87d-9c2287f28ff0)
