# Instructions for setting up empathic accuracy slider in Qualtrics.

## Written by Desmond C. Ong, github.com/desmond-ong
#### last updated October 2016

Demo: https://stanforduniversity.qualtrics.com/SE/?SID=SV_2nq4tQBeLrejhDD

What this script does is to create a 100-point slider whose values are captured every X seconds. (Default is every 0.5s, or 500 msec). This allows the participant to make continuous ratings while watching a video.

You can edit the instructions to have participants rate e.g. their own feelings, the feelings of the person in the video, and so forth. For the purposes of the explanation below, I'm assuming that the participant is rating the valence of the person in the video.

For each video, there are 3 variables stored:

1. The name of the video ("movieX_name")
2. The vector of slider values from 0-100 ("movieX_valence_vector")
3. The vector of time values in milliseconds ("movieX_time_vector")


If you are sampling every 500 milliseconds (the default), in an ideal world, the vector of time values will be e.g. 0, 500, 1000, 1500... But in practice, individual computers will have some lag/latency, and so having a vector of these time values will allow you to interpolate the valence values, and compare ratings across different participants.


At a high level, I use Qualtrics' "embedded data", which can be anything (a single number, a string). In this case, I use the embedded data to store a vector. So the slider-values variable will be "['50', '55', '57', '57'...]". where the numbers represent the value of the slider.


Default values:

- Slider is 100 points, slider handle starts visible in center (at 50).
- Slider values are sampled every 500 milliseconds
- Assumes that the video will be played at a resolution of 576 x 432
    - if you want to change this, look for the following code: `<video height="432" id="videoElement" preload="" width="576">` in the HTML portion of the instructions below, and modify the values accordingly


### Nuts and bolts

There are 3 steps (+ 1 for getting the data).

1. Declares the variables (as “embedded data”)
    - This step initializes the data variables that will be stored
2. Add Javascript code to your question (this is the meat of it)
    - This step contains the meat of the slider code, the sampling code.
3. Add HTML code to place the video in the question. 
    - This step creates the "video element" div, and loads a few necessary javascript files
    - This is the trickiest part, and you may end up erasing your HTML code when you edit the question in the future.
4. Downloading the data 


Note that you need to add at least an empty block IN BETWEEN trials. I haven't really figured out why, but I've found that it's best to just put an empty block that automatically proceeds on if you want continuous trials.




#### 1. Declaring Variables

In Survey Flow, click "Set Embedded Data" 

- add the following variables:
    - "movie1_name"
    - "movie1_valence_vector"
    - "movie1_time_vector"
- and their values should be "Value will be set from Panel or URL".
- Repeat the above step for each video you have. (movie2_name, movie2_valence_vector...) So if you have X videos, you should have 3X variable names. 
- Move the Embedded Data block before *any* block that calls on the slider code. (I would put it at the start of your survey, to be safe)


#### 2. Adding Javascript

NOTE: Create a separate Qualtrics question FOR EACH VIDEO. I would also put them in separate blocks.

Create the question that you want (I would recommend "Descriptive Text"). Write your instructions.

Then, on the question in Qualtrics, click the little wheel on the left right below the question name, then click "Add Javascript".

- Add the following chunk of code.
- Note that there are several values that you have to change:
    - `URL_OF_VIDEO`
        - The URL should be a full path to directly to a video file: 'https://www.myInstitution.edu/~me/myVideos/vid1.mp4'
        - Note: a link to a YouTube video won't work. Note that the URL points directly to the video file, like an .mp4 file.
        - Note: the URL should be surrounded by inverted commas, and should include https:// at the start.
    - `NAME_OF_VIDEO`
        - This is just a string that will populate your "movie1_name" variable above.
    - `DURATION_OF_VIDEO_IN_MILLISECONDS`
        - The sampling script will sample for DURATION_OF_VIDEO_IN_MILLISECONDS milliseconds. Thus, I would recommend adding a buffer of 500 milliseconds at the end just so the script doesn't end before the video. 
        - These three variables are all at the start of the JS chunk.
    - the first argument to the `Qualtrics.SurveyEngine.setEmbeddedData` commands at the bottom. 
        - For example, if this is the second movie, you’ll need to change 'movie1_name' to 'movie2_name', and so forth.
    - I left the number on the scale as a label on the slider handle for troubleshooting purposes (e.g., it starts at 0, and the number goes negative as you drag it to the left, and positive if you drag it to the right). If you wish to remove the label on the slider handle, change the variable in following line from `true` to `false`
        - with label: `var addLabel = true;`
        - without label: `var addLabel = false;`
` 

```
Qualtrics.SurveyEngine.addOnload(function()
{
  /*Place Your Javascript Below This Line*/
  var URL_OF_VIDEO = 'https://https://www.myInstitution.edu/~me/myVideos/vid1.mp4';
  var NAME_OF_VIDEO = 'this movie';
  var DURATION_OF_VIDEO_IN_MILLISECONDS = 155000 + 500; // in milliseconds. Note the 500 at the end is a buffer
  var TIME_INTERVAL_IN_MILLISECONDS = 500; // default: sample every 500 milliseconds
  var current_valence_vector = [];
  var current_time_vector = [];
  
  function mySliderFunction(paper, inputX, inputY, pathString, colour, pathWidth) {
    var addLabel = true; // boolean to change if you want the slider to be labeled with the current value.
    
    var slider = paper.set();
    
    slider.currentValue = 50; // setting the initial value of the slider
    slider.push(paper.path("M" + inputX + " " + inputY + pathString)).attr({stroke:colour,"stroke-width": pathWidth});
    slider.PathLength   = slider[0].getTotalLength();

    slider.PathPointOne = slider[0].getPointAtLength(0); // left edge of slider
    slider.PathPointTwo = slider[0].getPointAtLength(slider.PathLength);  // right edge of slider; depends on the pathString that's input.
    slider.PathBox      = slider[0].getBBox();
    slider.PathBoxWidth = slider.PathBox.width;
    slider.push(paper.circle(slider.PathPointOne.x, slider.PathPointOne.y, pathWidth/2).attr({fill:colour, "stroke-width": 0,"stroke-opacity": 0})); // left edge
    slider.push(paper.circle(slider.PathPointTwo.x, slider.PathPointTwo.y, pathWidth/2).attr({fill:colour, "stroke-width": 0,"stroke-opacity": 0})); // right edge

    /*Slider Button*/
    // creating the "back" of the slider button, sButtonBack
    //    paper.circle(  x position,   y position,   radius of circle   )
    //  so the initial x position is in the center of the slider
    //  the .attr() call is to change the fill color, stroke width, and other graphical attributes
    slider.sButtonBack = paper.circle(slider.PathPointOne.x + slider.PathLength/2, slider.PathPointOne.y, pathWidth);
    slider.sButtonBack.attr({fill: "#777","stroke-width": 1,"fill-opacity": 1, stroke: "#000", r:(15)});
    slider.push(slider.sButtonBack); // drawing sButtonBack on the canvas  

    if(addLabel) {
    // adding a text label to the slider handle (i.e. number from 0 to 100)
      sliderText=paper.text((slider.PathPointOne.x + slider.PathPointTwo.x)/2, slider.PathPointOne.y, slider.currentValue ).attr({fill:'#FFF', 'font-size':16, 'stroke-width':0 });
      slider.push(sliderText);
    }
    // similarly creating the slider button itself.
    slider.sButton = paper.circle(slider.PathPointOne.x + slider.PathLength/2, slider.PathPointOne.y, pathWidth);
    slider.sButton.attr({fill: "#777","stroke-width": 1,"fill-opacity": 0.1, stroke: "#000", r:(15)} );
    
    // We also want to add other attributes/functionality to the sButton
    var start = function () { this.ox = this.attr("cx"); },
    move = function (dx, dy) {
      proportionAlongLine = (this.ox + dx - inputX)/slider.PathBoxWidth;
      // reusing "PathPointOne" to store current point
      slider.PathPointOne = slider[0].getPointAtLength(proportionAlongLine * slider.PathLength);

      if (!slider.PathPointOne.x) { slider.PathPointOne.x=x1; }
      if (!slider.PathPointOne.y) { slider.PathPointOne.y=y1; }
      this.attr({cx: slider.PathPointOne.x, cy: slider.PathPointOne.y}); 
     slider.sButtonBack.attr({cx: slider.PathPointOne.x, cy: slider.PathPointOne.y});

     // just adding a check so that the "cx" doesnt go beyond the left edge.
     if (Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100)) {
        slider.currentValue=Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100);  
      } else {
        slider.currentValue=0;
      }
      if(addLabel) { // adding an label to the slider handle
        sliderText.attr({text:slider.currentValue, x: slider.PathPointOne.x, y: slider.PathPointOne.y});
      }
    },
    up = function () {
      // 
    }; 
    // assign the 'move', 'start', and 'up' functions to the slider button
    //   see raphael.js documentation for more details, but the inputs are:
    //   1) what to do when element is moved ("mouse move")
    //   2) what to do on the start of the element being dragged ("mouse start")
    //   3) what to do when the element is released ("mouse up")
    slider.sButton.drag(move, start, up);
    slider.push(slider.sButton); // draw sButton onto the canvas.
    return slider;
  };
  

  // loading the video into the html element
  videoElement = document.getElementById("videoElement");
  videoElement.setAttribute("src", URL_OF_VIDEO);
  videoElement.load();
  
  // creating the canvas onto which to paint the slider
  canvas = Raphael('happySliderDiv'); 

  LeftEdge = 200;
  RightEdge = 500;
  textYCoord = 40;
  
  // creating the end points of the slider
  canvas.text(LeftEdge, textYCoord, "Very Negative").attr({ "font-size": 24 });
  canvas.text(RightEdge, textYCoord, "Very Positive").attr({ "font-size": 24 });

  // creating the slider variable  
  mySlider = mySliderFunction(canvas, LeftEdge, 75, 'h300',"#AAAAAA", 15);

  // this function startTiming gets called when the start button is pressed.
  function startTiming() {
    videoElement.play();
    timeAtStart = new Date().getTime();
    current_valence_vector.push(mySlider.currentValue);
    current_time_vector.push(0);
    
    // this is the sampling function, every TIME_INTERVAL_IN_MILLISECONDS milliseconds
    myInterval = setInterval(function() {
      timeNow = new Date().getTime() - timeAtStart;
      current_valence_vector.push(mySlider.currentValue);
      current_time_vector.push(timeNow);
    }, TIME_INTERVAL_IN_MILLISECONDS);

    // this function waits for DURATION_OF_VIDEO_IN_MILLISECONDS milliseconds, then stops the sampling script and saves the data.
    setTimeout(function() {
      clearInterval(myInterval);
      Qualtrics.SurveyEngine.setEmbeddedData('movie1_name', NAME_OF_VIDEO);
      Qualtrics.SurveyEngine.setEmbeddedData('movie1_valence_vector', current_valence_vector);
      Qualtrics.SurveyEngine.setEmbeddedData('movie1_time_vector', current_time_vector);
      canvas.text(350, 200, "Ok, you are done with this page.").attr({ "font-size": 24 });
      canvas.text(350, 240, "Please click the blue arrow to proceed!").attr({ "font-size": 24 });
    }, DURATION_OF_VIDEO_IN_MILLISECONDS);
  };
  

  goButton = canvas.rect(300,125,100,25,0).attr({fill: "#0f0"});
  goButton.click(function() {
    startTiming();
    goButton.hide();
  });
  
});
```




#### 3. Adding HTML

Finally, within the question, click "HTML view", and add the following HTML:

This is the part that most often screws up, because you may accidentally remove the HTML code while editing the question! Be sure to double check this!

```
<script src="https://rawgit.com/desmond-ong/common/master/js/jquery.min.js" type="text/javascript"></script> 
<script src="https://rawgit.com/desmond-ong/common/master/js/raphael.js" type="text/javascript"></script> 
<script>
var $j = jQuery.noConflict();
</script>
<center>
<video height="432" id="videoElement" preload="" width="576"></video>

<div id="happySliderDiv" style="height:350px; width:100%">&nbsp;</div>
</center>
```

#### 4. Downloading the data

Once you've pilot tested your script, or ran some participants, and want to download your data, make sure you download it in .csv format. The data are vectors (e.g. "['50', '55', '57', '57'...]"), and I think some data formats might not correctly recognize the vectors.

- The data comes out correctly when you export the data, as opposed to viewing it in the data table. 
    - Using the Qualtrics interface, go to: "Data & Analysis", "Export & Import", "Export Data", "Export Data with Legacy Format", then "CSV"
    - You keep the "use legacy View Results format" box checked, in which you'll have 2 header rows. If you uncheck this, you'll have 3 header rows.
    - I do not use the other formats (XML, SPSS, etc) so I don't know whether they'll work. I suspect they should.
- If you use R, you can can use [this awesome script](https://www.github.com/desmond-ong/QualtricsToR) to help you download it automatically into R via the Qualtrics API.
- I do know that the "Data Table" view within the Qualtrics interface will *NOT* show the vectors, so it will seem like the data did not get saved properly.
    - In particular, exporting the "Data Table" to .csv will *NOT* work.


Now, once you have the vector data, how do you process it? Well, that would depend on how you want to store your data and if you want to do any preprocessing. At the very least, you could:

1. write a simple (e.g. python) script to read in the vectors and convert it into another format, e.g. a wide format with one file for each video, and time as rows and participants' responses as columns.
2. do some preprocessing: such as standardizing the time interval sampling (some slower computers might have less recorded values for the same length video because of higher latency between the samples). I would suggest some simple interpolation (e.g. using `numpy.interp`).

And then you can proceed to do analyses on the time series data.


I have my own scripts for my own data, which, if I see enough general-purpose-use, will document here as well (since I have my own data processing convention). Email me if you have any questions.



###### Acknowledgements

Special thanks to Qualtrics support for helping me with a couple of issues, and to my first couple of users who provided feedback: June Gruber, Erika Weisz, Yoni Ashar


