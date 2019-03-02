# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=master)](https://travis-ci.org/newdigate/teensy-blink)
A reference example and guide to integrating a teensy project on github with travis continuous integration

When you make/push any changes to a branch of your repo on github, travis will fetch download the branch with changes and trigger a build. Travis will also trigger a build if somebody sends you a pull-request. This allows you to determine if the pull request will break your build (i.e cause build/compiler errors when your merge it)...  

## guide to integrating your github teensy project with travis 
Firstly, you need a [.travis.yaml](https://github.com/newdigate/teensy-blink/blob/master/.travis.yml) (.yaml format) in the root folder of your repository 

The .travis.yaml file allows you to specify build agent requirements, dependencies, install scripts for your repo:
``` yaml
matrix:
  include:
    - language: c
      sudo: false
      install:
        - export ARDUINO_IDE_VERSION="1.8.7"
        - wget --quiet https://downloads.arduino.cc/arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz
        - tar xf arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz -C $HOME/arduino_ide/
        - $HOME/arduino_ide/arduino --pref "boardsmanager.additional.urls=https://github.com/newdigate/teensy-build/raw/master/package_teensyduino_index.json" --save-prefs
        - $HOME/arduino_ide/arduino --install-boards teensyduino:avr
      script:
        - $HOME/arduino_ide/arduino --verify --verbose --board "teensyduino:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" blink/blink.ino 
        
notifications:
  email:
    on_success: change
    on_failure: change
```

## some notes
 * need a "package_index" url for arduino board-manager
   * [package_teensyduino_index.json](https://github.com/newdigate/teensy-build/blob/master/package_teensyduino_index.json)
   * `arduino --pref "boardsmanager.additional.urls=https://github.com/newdigate/teensy-build/raw/master/package_teensyduino_index.json" --save-prefs`
     * adds teensy3.6 to board-manager
   * `arduino --install-boards teensyduino:avr`
     * downloads teensy cores and bundled libraries
     * downloads arm-none-eabi-gcc 5.4.1 toolchain
   * `arduino --verify --verbose --board "teensyduino:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" blink/blink.ino  `
     * compiles blink.ino sketch for teensy 3.6
 * precompile_helper.c
   * used by teensyduino to cache compiled code
   * download and compile inline on build agent 
 * substitute arm libs with correct hardware-based fpu linked libraries
   * `tools/gcc-arm-none-eabi-gcc/5.4.1-2016q2/arm-none-eabi/lib`
   * needs to be changed with the lib files from `teensyduino tools/arm/arm-none-eabi/lib`
 
## links 
* https://www.pjrc.com/teensy/td_download.html
* https://learn.adafruit.com/continuous-integration-arduino-and-you/testing-your-project
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.6.x-package_index.json-format-specification
* https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc
