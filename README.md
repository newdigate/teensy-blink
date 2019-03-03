# teensy-blink [![Build Status](https://travis-ci.org/newdigate/teensy-blink.svg?branch=teensyduino-installer)](https://travis-ci.org/newdigate/teensy-blink)
A reference example and guide to integrating a teensy project on github with travis continuous integration

* A quick-guide here: [quick guide](quick-guide.md)
* More details are here: [details](detail-guide.md)

## To-do
* use teensyduino installer for linux, instead of having to patch gcc-arm-none-eabi libs.
* make teensyduino platform available in arduino gui apps board manager

## Other projects using teensy-build 
* [teensy-midi-looper](https://github.com/newdigate/teensy-midi-looper)

## General idea of continuous integration
When you make/push any changes to a branch of your repo on github, travis will fetch download the branch with changes and trigger a build.  

Travis will also trigger a build if somebody sends you a pull-request. This allows you to determine if the pull request will break your build (i.e cause build/compiler errors when your merge it)...  

### git workflow
Once your repo's is integrated with jenkins, when you wish to make changes to your repo, you can create "feature" branches, instead of committing directly to master repo. see [Git-Branching-Branching-Workflows](https://git-scm.com/book/en/v1/Git-Branching-Branching-Workflows).


## Links 
* https://www.pjrc.com/teensy/td_download.html
* https://learn.adafruit.com/continuous-integration-arduino-and-you/testing-your-project
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.5-3rd-party-Hardware-specification
* https://github.com/arduino/Arduino/wiki/Arduino-IDE-1.6.x-package_index.json-format-specification
* https://github.com/arduino/Arduino/blob/master/build/shared/manpage.adoc
