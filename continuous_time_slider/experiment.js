function showSlide(id) {
  $(".slide").hide();
  $("#"+id).show();
}


 function mySliderFunction(paper, inputX, inputY, pathString, colour, pathWidth) {
   var addLabel = false; // boolean to change if you want the slider to be labeled with the current value.

   var slider = paper.set();
   slider.currentValue = 50; // setting the initial value of the slider
   
   // creating the slider variables
   slider.push(paper.path("M" + inputX + " " + inputY + pathString)).attr({stroke:colour,"stroke-width": pathWidth});
   slider.PathLength   = slider[0].getTotalLength();

   slider.PathPointOne = slider[0].getPointAtLength(0); // left edge of slider
   slider.PathPointTwo = slider[0].getPointAtLength(slider.PathLength); // right edge of slider; depends on the pathString that's input.
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
     
     if (!slider.PathPointOne.x) { slider.PathPointOne.x = inputX; }
     if (!slider.PathPointOne.y) { slider.PathPointOne.y = inputY; }
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
   up = function () {}; // empty function, because we don't do anything on mouse up (releasing the slider).  

   // assign the 'move', 'start', and 'up' functions to the slider button
   //   see raphael.js documentation for more details, but the inputs are:
   //   1) what to do when element is moved ("mouse move")
   //   2) what to do on the start of the element being dragged ("mouse start")
   //   3) what to do when the element is released ("mouse up")
     slider.sButton.drag(move, start, up);
     slider.push(slider.sButton); // draw sButton onto the canvas.
     return slider;
};







var videoElement;
var videoLength = 10000; // in milliseconds
var SAMPLING_INTERVAL = 500; // in milliseconds

// the main experiment object 
var experiment = {
  valenceVector: [],
  timeVector: [],

  afterEA: function() {
    /*
    The function that gets called when the EA sequence is finished.
    */
    experiment.end();
  },

  end: function() {
    // Show the finish slide.
    showSlide("finished");

    /*
    Wait 1.5 seconds and then submit the whole experiment object to Mechanical Turk (mmturkey filters out the functions so we know we’re just submitting properties [i.e. data])
    */
    setTimeout(function() { turk.submit(experiment);}, 1500);
  },



  setup: function() {
    showSlide("stage");
    canvas = Raphael('happySliderDiv');
    
    videoElement = document.getElementById("videoElement");
    videoElement.setAttribute("src", "videos/CMJustIn.mp4");
    videoElement.load();
    
    LeftEdge = 200;
    RightEdge = 500;
    textYCoord = 40;
    
    canvas.text(LeftEdge, textYCoord, "Negative").attr({ "font-size": 24 });
    canvas.text(RightEdge, textYCoord, "Positive").attr({ "font-size": 24 });
    
    mySlider = mySliderFunction(canvas, LeftEdge, 75, 'h300',"#AAAAAA", 15);
    goButton = canvas.rect(300,125,100,25,0).attr({fill: "#0f0"});
    goButton.click(function() {
        experiment.startTiming();
        goButton.hide();
      });
    $('#nextButton').hide();
  },

  startTiming: function() {
    videoElement.play();
    timeNow = (new Date()).getTime();
    
    
    experiment.timeVector.push(0);
    experiment.valenceVector.push(mySlider.currentValue);

    myInterval = setInterval(function() {
      experiment.timeVector.push((new Date()).getTime() - timeNow);
      experiment.valenceVector.push(mySlider.currentValue);
    }, SAMPLING_INTERVAL);

    setTimeout(function() {
      clearInterval(myInterval);
      canvas.text(350, 150, "Ok, you are done with this page.").attr({ "font-size": 24 });
      canvas.text(350, 190, "Please click the button to proceed!").attr({ "font-size": 24 });
      $('#nextButton').show();
    }, videoLength);
  },


};

experiment.setup();
