# Continuous Time Slider

This Widget provides a slider that people can modify while watching a video. This allows the participant to rate, for example, how they themselves are feeling on a second-by-second basis, or how a character in a movie is feeling. The slider's value is captured every X seconds, and the data is stored in a vector.

In the demo below, it's a 100 point slider, set to be sampled every 0.5s. Click on the demo to watch Cookie Monster play bowling!

Demo: http://rawgit.com/desmond-ong/psychWidgets/master/continuous_time_slider/index.html

Send feedback to desmond (dot) ong (at) stanford (dot) edu. and let me know if you do end up using this widget! 

## How to Use

There is a HTML component and a Javascript component.

- The HTML sets up the question prompt and a container div to hold the slider and other animation. It also loads the respective helper libraries: Raphael.js, jquery, and mmturkey.js
- mmturkey.js is a javascript file that our lab (Stanford Computation and Cognition Lab) uses to handle the interfacing with Mechanical Turk. You don't have to worry too much about it.

In the Javascript,
- mySliderFunction is the main code that takes in a lot of variables, such as the starting x positions, etc. You can modify it if you wish to fit your experiment.

- experiment.setup() loads the videos and creates the sliders and buttons.
- experiment.startTiming() starts an interval function (to sample the value of the slider every SAMPLING_INTERVAL milliseconds) and a timeout function (to be called after the video ends).


## Qualtrics version

I also have a version that can be incorporated into a Qualtrics survey.
The instructions are [here](QualtricsReadme.md).

## Matlab version

I've also included a Matlab version (rateVideo.m) that's a working skeleton of one of my existing experiments. Do let me know if you have any problems getting this to work on your system. This requires Matlab, Psychtoolbox, and any other dependencies you may need to play multimedia (e.g. gstreamer on Windows). 

Also, I wrote this using a Mac and have gotten it to work (with some modifications) on Windows. If you're running Windows, do note that Matlab has a lot of annoying cross-platform differences, so if your problem is due to e.g. PCs using `\` and Macs using `/`, please try to fix that yourself. Those should be the only differences. [You should also try some of the demos at: http://psychtoolbox.org/]

## PsychoPy version

My old labmate Emma Templeton has written a version of this in PsychoPy! Her github repo can be found [here](https://github.com/emtempleton/ConversationRatings).

## References and Acknowledgements

Dependencies: utilizes Raphael JS: http://www.raphaeljs.com

Note that all the links right now in my code are to my own copies of Raphael, jquery, etc. Do make your own copies if you choose to deploy this widget!
