function showSlide(id) {
  $(".slide").hide();
  $("#"+id).show();
}


 function mySliderFunction(paper, x1, y1, pathString, colour, pathWidth) {
   var slider = paper.set();
   var position=0;
   slider.currentValue=50;
   slider.push(paper.path("M"+x1+" "+y1+pathString)).attr( {stroke:colour,"stroke-width": pathWidth } );
   slider.PathLength   = slider[0].getTotalLength();

   slider.PathPointOne   = slider[0].getPointAtLength(position);
   slider.PathPointTwo   = slider[0].getPointAtLength(slider.PathLength);
   slider.PathBox      = slider[0].getBBox();
   slider.PathBoxWidth   = slider.PathBox.width;
   slider.push(paper.circle(slider.PathPointOne.x, slider.PathPointOne.y, pathWidth/2).attr(   {fill:colour, "stroke-width": 0,"stroke-opacity": 0 }) );         
   slider.push(paper.circle(slider.PathPointTwo.x, slider.PathPointTwo.y, pathWidth/2).attr(   {fill:colour, "stroke-width": 0,"stroke-opacity": 0 }) );
   
   /*Slider Button*/
   slider.sButtonBack=paper.circle(slider.PathPointOne.x + slider.PathLength/2, slider.PathPointOne.y, pathWidth);
   slider.sButtonBack.attr({ fill: "#777","stroke-width": 1,"fill-opacity": 1, stroke: "#000"  } );
   slider.sButtonBack.attr({r:(15)});
   slider.push(slider.sButtonBack);   
   slider.sButton=paper.circle(slider.PathPointOne.x + slider.PathLength/2, slider.PathPointOne.y, pathWidth);
   slider.sButton.attr({    fill: "#777","stroke-width": 1,"fill-opacity": 0.1, stroke: "#000"  } );
   slider.sButton.attr({r:(15)});
   
   var start = function () {
     this.ox = this.attr("cx");
   },
   move = function (dx, dy) {
       pcAlongLine = (this.ox+dx-x1)/slider.PathBoxWidth;
       slider.PathPointOne = slider[0].getPointAtLength(pcAlongLine*slider.PathLength);
     
     if (!slider.PathPointOne.x) { slider.PathPointOne.x=x1; }
     if (!slider.PathPointOne.y) { slider.PathPointOne.y=y1; }
     att = {cx: slider.PathPointOne.x, cy: slider.PathPointOne.y};
     this.attr(att); slider.sButtonBack.attr(att);
     if (Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100)) {
       slider.currentValue=Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100);  
     } else {
       slider.currentValue=0;
     }
     
   },
   up = function () {
     // 
   };  
     slider.sButton.drag(move, start, up);
     slider.push(slider.sButton);                     
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
      });
    $('#nextButton').hide();
  },

  startTiming: function() {
    videoElement.play();
    timeNow = (new Date()).getTime();
    currentString = "happy_" + timeNow + "s";
    goButton.hide();
    
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
