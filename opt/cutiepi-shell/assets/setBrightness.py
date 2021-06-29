#!/usr/bin/python

import sys
import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

GPIO.setup(12, GPIO.OUT)

p = GPIO.PWM(12, 50)
p.ChangeFrequency(120)
p.start(0)

brightness = float(sys.argv[1])
try:
    while 1:
        p.ChangeDutyCycle(brightness)
except KeyboardInterrupt:
    pass
p.stop()
GPIO.cleanup()
