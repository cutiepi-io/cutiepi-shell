#!/bin/bash

pactl -- set-source-volume 1 240%
arecord -d 3 -f cd > /tmp/test.wav
paplay /tmp/test.wav
