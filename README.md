# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=master)](https://travis-ci.org/newdigate/teensy-blink)

## recipe for compiling teensy sketches in jenkins
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
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.6.x-package_index.json-format-specification
* https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc
