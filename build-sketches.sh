#!/usr/bin/env bash
examples=($(find $HOME/build -name "*.pde" -o -name "*.ino"))
for example in "${examples[@]}"; do
  $HOME/arduino_ide/arduino-$ARDUINO_IDE_VERSION/arduino --verify --verbose --board "teensy:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" $example
done;
