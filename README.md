# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=teensyduino-installer)](https://travis-ci.org/newdigate/teensy-blink)
A reference example and guide to integrating a teensy project on github with travis continuous integration

## tldr - cheat-sheet
```.travis.yaml``` contents:
``` yaml
matrix:
  include:
    - language: c
      sudo: false
      install:
        #- set -v
        - export ARDUINO_IDE_VERSION="1.8.8"
        - wget --quiet https://downloads.arduino.cc/arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz
        - mkdir $HOME/arduino_ide
        - tar xf arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz -C $HOME/arduino_ide/ 
        - curl -fsSL https://www.pjrc.com/teensy/td_145/TeensyduinoInstall.linux64 -o TeensyduinoInstall.linux64
        - chmod +x TeensyduinoInstall.linux64
        - /sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_1.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :1 -ac -screen 0 1280x1024x16
        - sleep 3
        - export DISPLAY=:1.0
        - ./TeensyduinoInstall.linux64 --dir=$HOME/arduino_ide/arduino-$ARDUINO_IDE_VERSION
      script:
        - $HOME/arduino_ide/arduino --verify --verbose --board "teensyduino:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" blink/blink.ino 

notifications:
  email:
    on_success: change
    on_failure: change
```

* A quick-guide here: [quick guide](quick-guide.md)
* More details are here: [details](detail-guide.md)

## To-do
* ~~use teensyduino installer for linux, instead of having to patch gcc-arm-none-eabi libs.~~
* make teensyduino platform available in arduino gui apps board manager

## Other projects using teensy-build 
* [teensy-midi-looper](https://github.com/newdigate/teensy-midi-looper)

## General idea of continuous integration
When you push changes to a branch of your repo, travis will boot a vm container, fetch the branch, install necessary dependencies, and then verify the code by compiling it via the arduino command line interface (cli).  

Travis will also trigger a build if a pull-request is received on a branch of your repo. This allows you to determine if the pull-request will break your build (i.e cause build/compiler errors when your merge it)...And it gives people who contribute code some indication that there changes will at least not cause the compile stage to fail.   

### git workflow
Once your repo's is integrated with jenkins, when you wish to make changes to your repo, you can create "feature" branches, instead of committing directly to master repo. see [Git-Branching-Branching-Workflows](https://git-scm.com/book/en/v1/Git-Branching-Branching-Workflows).

## Links 
* https://www.pjrc.com/teensy/td_download.html
* https://learn.adafruit.com/continuous-integration-arduino-and-you/testing-your-project
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.6.x-package_index.json-format-specification
* https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc
