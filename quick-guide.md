# teensy github travis integration quick guide
**create ```.travis.yaml``` file in root dir of your repo** 
* substitute ```blink/blink.ino``` with your .ino sketch file
* if required, add any libraries which are not packaged with teensyduino and/or aduino; eg "Adafruit ST7735 and ST7789 Library" below...
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
        - $HOME/arduino_ide/arduino-$ARDUINO_IDE_VERSION/arduino --install-library "Adafruit ST7735 and ST7789 Library"
      script:
        - $HOME/arduino_ide/arduino-$ARDUINO_IDE_VERSION/arduino --verify --verbose --board "teensyduino:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" blink/blink.ino 

notifications:
  email:
    on_success: change
    on_failure: change
```

**create ```build-sketches.sh``` file in your repo**
This script will find and compile all .ino and .pde files
``` bash
#!/usr/bin/env bash
# define colors
GRAY='\033[1;30m'; RED='\033[0;31m'; LRED='\033[1;31m'; GREEN='\033[0;32m'; LGREEN='\033[1;32m'; ORANGE='\033[0;33m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; LBLUE='\033[1;34m'; PURPLE='\033[0;35m'; LPURPLE='\033[1;35m'; CYAN='\033[0;36m'; LCYAN='\033[1;36m'; LGRAY='\033[0;37m'; WHITE='\033[1;37m';
examples=($(find $HOME/build -name "*.pde" -o -name "*.ino"))
for example in "${examples[@]}"; do
  echo -n $example:
  local platform_stdout=$($HOME/arduino_ide/arduino-$ARDUINO_IDE_VERSION/arduino --verify --board "teensy:avr:teensy36:usb=serial,speed=180,opt=o2std,keys=en-us" $example 2>&1)
  # grab the exit status of the arduino board change
  local platform_switch=$?
  # notify if the platform switch failed
  if [ $platform_switch -ne 0 ]; then
    # heavy X
    echo -e """$RED""\xe2\x9c\x96"
    
    echo $platform_stdout
    exit_code=1
  else
    # heavy checkmark
    echo -e """$GREEN""\xe2\x9c\x93"
  fi
done;
```
