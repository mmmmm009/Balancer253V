
# Balancer253V
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
