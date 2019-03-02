# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=master)](https://travis-ci.org/newdigate/teensy-blink)
A reference example and guide to integrating a teensy project on github with travis continuous integration

When you make/push any changes to a branch of your repo on github, travis will fetch download the branch with changes and trigger a build. Travis will also trigger a build if somebody sends you a pull-request. This allows you to determine if the pull request will break your build (i.e cause build/compiler errors when your merge it)...  

## Guide to integrating your github teensy project with travis 
Firstly, you need a [.travis.yaml](https://github.com/newdigate/teensy-blink/blob/master/.travis.yml) (.yaml format) in the root folder of your repository 

The .travis.yaml file allows you to specify build agent requirements, dependencies, install scripts for your repo: **(this example does NOT work, just ideal world scenario)**
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

Unfortunately, the .travis.yaml above doesn't work as is and a couple of few work-arounds are required:

### no platforms_index.json file for teensy boards
Teensyduino doesn't have an official platforms_xxx_index.json which we could add to ```boardsmanager.additional.urls```, at least, not one that I know of. This file would allow you to use the native arduino packaging and board-management system, rather than having an external installer. My initial approach was to teensyduino installer and run "headless". 
``` sh
curl -fsSL https://www.pjrc.com/teensy/td_145/TeensyduinoInstall.linux64 -o TeensyduinoInstall.linux64
chmod +x TeensyduinoInstall.linux64
./TeensyduinoInstall.linux64 -dir=$HOME/arduino_ide/arduino
```
but unfortunately, was not able to get it working... (perhaps its wrong architecture, need x86_64, or perhaps need to export display correctly for x-windows?)
```
Can't open display: 
The command "./TeensyduinoInstall.linux64 -dir=$HOME/arduino_ide/arduino" failed and exited with 1 during .
```

So after many attempts, I crafted [platforms_teensyduino_index.json](https://github.com/newdigate/teensy-build/blob/master/package_teensyduino_index.json) which defines teensyduino:avr set of boards (It should be teensyduino:sam for teensy36 I think, but since the cores are stored under avr in teensyduino, its convenient... ) and references gcc-arm-none-eabi c++ toolcahin from https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads/5-2016-q2-update using arduinos built in tool management system. 



### some notes
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
