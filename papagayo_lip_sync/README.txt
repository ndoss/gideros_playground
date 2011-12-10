
* This is a quick & dirty example of using papagayo to create a lip sync'd 
  animation

* Software used in this example:
  - Gideros (http://www.giderosmobile.com/)
  - Papagayo (http://www.lostmarble.com/papagayo/)

* How I made the example ...
  - Get an audio file (example uses phrase.mp3)
  - Convert it to "wav" format (on linux, I used:  mpg123 -w phrase.wav phrase.mp3)
  - Process the wav file with papagayo
    - Open Papagayo and load the wav file (phrase.wav)
    - Change "Fps" (top right of the papagayo program) to 60 (default Gideros FPS is 60)
    - Type in text into "spoken text" part of the papagayo program
    - Click the "Breakdown" button
    - Move words around to align them with the audio file
    - Save the project (example saved as:  phrase.pgo)
  - Convert the pgo file to a "lst" file by running the perl script "pgoToLua.pl"
  - The example lua code reads the lst file to create a timeline for a Gideros MovieClip

* Files in the example:
  - main.lua - entry point to the gideros example
  - papagayo_lip_sync.gproj - gideros project file
  - mouth/*.png - images for the phonemes - these are the default mouth images for 
    "Mouth1" in papagayo
  - pgoToLua.pl - perl script that converts pgo file to lua table
  - phrase.mp3 - original mp3 audio file
  - phrase.wav - wav version of the phrase.mp3 file
  - sun.png - character image
