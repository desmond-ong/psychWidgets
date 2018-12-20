# Scalar Slider template

This sclar (continuous, 100 point) slider was modified by Erin Bennett and Justine Kao, among others, with light edits by myself. The base code is jquery ui: https://jqueryui.com/slider/

This Widget is a continuous animated slider.

Demo: https://desmond-ong.github.io/psychWidgets/scalar_slider_template/index.html

Send feedback to desmond (dot) ong (at) stanford (dot) edu. and let me know if you do end up using this widget! 

## How to Use

There is a HTML component, a Javascript component, and a CSS component (which I've embedded into the html)

- Within the HTML, line 81, there is a "slider0" div, which is basically the raw example from https://jqueryui.com/slider/
- There is also a hidden "input" object, which we call "hiddenSlider0", on line 82. When the slider is updated, we update the "value" attribute of this input object, so we can read from it later (just like a HTML input)
- The Javascript call to set up and initialize the slider is in experiment.js, lines 96-115
	- The various things it does are (more can be found at the jquery UI API):
		- sets up the min, max values, as well as the step size, and the initial value. Defaults: min 0 max 100 step size of 1 and value of 50
		- upon creation of the slider, hides the handle (line 100)
		- when slider animates, changes the background of the slider (line 111-115)
		- updates the value of "hiddenSlider" on line 110
- After each stage, we can record the values on the slider
	- line 119 records the value on the hiddenSlider input object
	- line 121 resets the slider div to be blank
	- line 122 resets the value on the hiddenSlider input object
- We can also do a check upon button click to ensure that a response was given
	- this is done in the HTML, lines 46-53.

- Lastly there's some CSS in lines 18-23 of the HTML file just to make things look pretty when fit into the table. I've also modified the jquery-ui.css file slightly, but it shouldn't make a difference even if you use the code from the jquery website.


So if you want to add more sliders, make sure you do the following:

- 1) create a div, and a hidden "input" object
- 2) update the validation script in the HTML (HTML lines 46-53)
- 3) copy and paste the slider setup code for each slider (JS lines 96-115)
- 4) copy and paste the "recording variables" and "resetting variables" code (JS lines 119-122)


## Notes

mmturkey.js is a javascript file that our lab uses to handle the interfacing with Mechanical Turk. You don't have to worry too much about it.

Note that all the links right now in my code are to my own copies of jquery, jqueri-ui (.js, .css), etc. Do make your own copies if you choose to deploy this widget!
