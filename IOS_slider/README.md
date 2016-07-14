# Continuous Inclusion of Other in Self Scale

The original Inclusion of Other in Self (IOS; Aron, Aron, & Smollan, 1992) consisted of a 7 point scale, that is meant to assess interpersonal closeness with a target (which can be someone else; yourself in the future; a group; an abstract concept like Nature). One example of the original scale is here: http://www.haverford.edu/psychology/ble/continuous_ios/originalios.html

This Widget is a continuous version of the IOS scale. Currently it's a 100 point slider.

Demo: http://rawgit.com/desmond-ong/psychWidgets/master/IOS_slider/index.html

Send feedback to desmond (dot) ong (at) stanford (dot) edu. and let me know if you do end up using this widget! 

## How to Use

There is a HTML component and a Javascript component.

- The HTML sets up the question prompt and a container div to hold the slider and wheels. It also calls the respective helper functions: the main one is Raphael.js. And of course, jquery.
- mmturkery.js is a javascript file that our lab uses to handle the interfacing with Mechanical Turk. You don't have to worry too much about it.

In the Javascript,
- mySliderFunction is the main code that takes in a lot of variables, such as the starting x positions, etc. You can modify it if you wish to fit your experiment.

- the code that sets up the widget is in experiment.showIOS, lines 129-150.
- line 154 reads off the current value on the slider.
- the label on the circle (default setting: "Bob"), can be modified on line 127, or on line 148.

## Notes

You might also want to hide the number on the slider. I've left it in for debugging purposes. If you don't want it, comment out line 87 ("sliderText.attr...") in the javascript.

I did not optimize the starting separation of the two circles, so it might be hard to do a proper mapping between the original 7 point Likert and this 100 point slider (although methodologically that might be impossible in itself, because people respond differently to Likerts and sliders).



## References and Acknowledgements

Aron, A., Aron, E. N., & Smollan, D. (1992). Inclusion of Other in the Self Scale and the structure of interpersonal closeness. Journal of personality and social psychology, 63(4), 596.

Dependencies: utilizes Raphael JS: http://www.raphaeljs.com

My code is modified from the example given here: http://irunmywebsite.com/jQuery/voter.php

Note that all the links right now in my code are to my own copies of Raphael, jquery, etc. Do make your own copies if you choose to deploy this widget!