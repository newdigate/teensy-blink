# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=master)](https://travis-ci.org/newdigate/teensy-blink)
A reference example and guide to integrating a teensy project on github with travis continuous integration

## General idea of continuous integration
When you make/push any changes to a branch of your repo on github, travis will fetch download the branch with changes and trigger a build.  

Travis will also trigger a build if somebody sends you a pull-request. This allows you to determine if the pull request will break your build (i.e cause build/compiler errors when your merge it)...  

### git workflow
Once your repo's is integrated with jenkins, when you wish to make changes to your repo, you can create "feature" branches, instead of committing directly to master repo. see [Git-Branching-Branching-Workflows](https://git-scm.com/book/en/v1/Git-Branching-Branching-Workflows).

## Guide to integrating your teensy project on github with travis 
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

Unfortunately, the .travis.yaml above is ideal-world and doesn't work. A few work-arounds are required:
### teensyduino installer fails on travis build agent
My initial approach was to use teensyduino installer and run "headless". 
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

### no platforms_index.json file for teensy boards
Teensyduino doesn't have an official platforms_xxx_index.json which we could add to ```boardsmanager.additional.urls```, at least, not one that I know of. This file would allow you to use the native arduino packaging and board-management system, rather than having an external installer. 

So after many revisions, I crafted a [platforms_teensyduino_index.json](https://github.com/newdigate/teensy-build/blob/master/package_teensyduino_index.json) which defines teensyduino:avr set of boards (It should be teensyduino:sam for teensy36 I think, but since the cores are stored under avr in teensyduino, its convenient... ) and references gcc-arm-none-eabi c++ toolcahin from https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads/5-2016-q2-update using arduinos built in tool management system. 

### gcc-arm-none-eabi libs are soft fpu compiled, not hard fpu.
Unfortunately, the libraries for linking c++ std libraries, which are bundled with gcc-arm-none-eabi 5.4.1-2016q2, are compiled for software floating point unit (fpu) and not hardware fpu; I have created a github repo containing the hardware-fpu-linked libraries [arm-none-eabi-teensy-libs](https://github.com/newdigate/arm-none-eabi-teensy-libs) which I copied from teensyduino tools/arm folder. 

### gcc-arm-none-eabi is i386 arch
build agent is x86_64 arch. gcc-arm-none-eabi-g++ fails if i386 arch is not installed. 
```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386
```

### a few extra dependencies
#### precompile_helper
download from https://github.com/PaulStoffregen/precompile_helper
``` bash
wget --quiet https://raw.githubusercontent.com/PaulStoffregen/precompile_helper/master/precompile_helper.c
gcc precompile_helper.c -o precompile_helper
```
#### stdout_redirect, and teensy_post_compile
I've disabled these steps in the "receipy" in teensyduino [platform.txt](https://github.com/newdigate/teensy-build/blob/master/teensyduino/platform.txt); stdout_redirect seems to be used as " < " redirect operator, my guess is that it is a work-around, becuase windows doesn't have a redirect cmd equivalent. I think it used to redirect the output of objdump to dump symbols to text files. 

``` csh
## Post Build - inform Teensy Loader of new file
#recipe.hooks.postbuild.1.pattern="{compiler.path}stdout_redirect" "{build.path}/{build.project_name}.lst" "{compiler.path}{build.command.objdump}" -d -S -C "{build.path}/{build.project_name}.elf"
#recipe.hooks.postbuild.2.pattern="{compiler.path}stdout_redirect" "{build.path}/{build.project_name}.sym" "{compiler.path}{build.command.objdump}" -t -C "{build.path}/{build.project_name}.elf"
#recipe.hooks.postbuild.3.pattern="{compiler.path}teensy_post_compile" "-file={build.project_name}" "-path={build.path}" "-tools={compiler.path}" "-board={build.board}"
```

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
