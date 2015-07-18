
/*
showSlide(id)
Displays each slide
*/

function showSlide(id) {
  $(".slide").hide();
  $("#"+id).show();
}


// main chunk of code for the slider.
// modified from: http://irunmywebsite.com/jQuery/voter.php
function mySliderFunction(paper, x1, y1, pathString, colour, pathWidth, iOSCircle1, iOSCircle2, LCircleEdge, RCircleEdge) {
    // paper: the Raphael paper object for the entire IOS widget
    // x1: the x location, in this case, of the left circle's left edge
    // y1: the y location
    // pathString: the string that defines the path of the slider. E.g. h200 means horizontal, 200 pixels.
    // color: the color of the slider background
    // pathWidth: the width of the slider

    // iOSCircle1 and 2: the circle objects. They are separate Raphael objects, which will be manipulated/animated by this function
    // LCircleEdge and RCircleEdge: the edges of the L and R circles respectively. This is needed to interpolate the iOSCircles


    //var paper = this;
    var slider = paper.set();
    var sliderOut=function(pcOut){ if(sliderOutput){ sliderOutput(pcOut); } };
    var position=0;
    slider.currentValue=0;
    //var percentageMax=percentageMax?percentageMax:100;
    slider.push(paper.path("M"+x1+" "+y1+pathString)).attr( {stroke:colour,"stroke-width": pathWidth } );
    slider.PathLength   = slider[0].getTotalLength();
      
      initialValue = 0;

    slider.PathPointOne   = slider[0].getPointAtLength(position);
    slider.PathPointTwo   = slider[0].getPointAtLength(slider.PathLength);
    slider.PathBox      = slider[0].getBBox();
    slider.PathBoxWidth   = slider.PathBox.width;
    slider.push(paper.circle(slider.PathPointOne.x, slider.PathPointOne.y, pathWidth/2).attr(   {fill:colour, "stroke-width": 0,"stroke-opacity": 0 }) );         
    slider.push(paper.circle(slider.PathPointTwo.x, slider.PathPointTwo.y, pathWidth/2).attr(   {fill:colour, "stroke-width": 0,"stroke-opacity": 0 }) );
    /*Slider Button*/
    sButtonBack=paper.circle(slider.PathPointOne.x, slider.PathPointOne.y, pathWidth);
    sButtonBack.attr({ fill: "#777","stroke-width": 1,"fill-opacity": 1, stroke: "#000"  } );
    sButtonBack.attr({r:(15)});
    slider.push(sButtonBack);   
    sliderText=paper.text(slider.PathPointOne.x,slider.PathPointOne.y,initialValue ).attr({fill:'#FFF', 'font-size':16, 'stroke-width':0 });
    slider.push(sliderText);
    sButton=paper.circle(slider.PathPointOne.x, slider.PathPointOne.y, pathWidth);
    sButton.attr({    fill: "#777","stroke-width": 1,"fill-opacity": 0.1, stroke: "#000"  } );
    sButton.attr({r:(15)});
    
    //sButton.mouseout(function (e) { this.attr({"fill-opacity": 0.1, "stroke-width":1}); });
    //sButton.mouseover(function (e){ this.attr({"fill-opacity": 0.3, "stroke-width":3}); });   
    var start = function ()
    {
      this.ox = this.attr("cx");
    },
    move = function (dx, dy)
    {
      //if ((this.ox+dx-x1)/slider.PathBoxWidth) {
        pcAlongLine = (this.ox+dx-x1)/slider.PathBoxWidth;
      //} else {
      //  pcAlongLine = 0;
      //}
      //if (slider[0].getPointAtLength(pcAlongLine*slider.PathLength)) {
        slider.PathPointOne = slider[0].getPointAtLength(pcAlongLine*slider.PathLength);
      //} else {
      //  slider.PathPointOne = slider[0].getPointAtLength(0);
      //}
      if (!slider.PathPointOne.x) {
        slider.PathPointOne.x=x1;
      }
      if (!slider.PathPointOne.y) {
        slider.PathPointOne.y=y1;
      }
      att = {cx: slider.PathPointOne.x, cy: slider.PathPointOne.y};
      this.attr(att);sButtonBack.attr(att);
      if (Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100)) {
        slider.currentValue=Math.round(((this.attr("cx")-slider.PathBox.x)/slider.PathBox.width)*100);  
      } else {
        slider.currentValue=0;
      }
      
      sliderText.attr({text:slider.currentValue,x: slider.PathPointOne.x, y: slider.PathPointOne.y});
      bbox=sliderText.getBBox();
//      sButton.attr({r:(bbox.width/2)});
//      sButtonBack.attr({r:(bbox.width/2)});
      sButton.attr({r:(15)});
      sButtonBack.attr({r:(15)});
      sliderOut(slider.currentValue);
    },
    up = function () 
    {
      // 
    };  
    sliderOutput=function(currentValue)
    { 
      var scale = (RCircleEdge - LCircleEdge)/100/2;
      //var scale = 500/200;
      //spinnerOutcome.transform("t" + currentAngle + " " + 256 + " " + 150); 
      iOSCircle1.transform("t" + currentValue*scale + ",0"); 
      iOSCircle2.transform("t-" + currentValue*scale + ",0"); 


    };

    returnValue = function() {
      return currentValue;
    }

    sButton.drag(move, start, up);
    slider.push(sButton);                     
        return slider;
    };





// the main experiment object that 
var experiment = {

  iOS: -1,
  characterName: "Bob", // change this to the other label on your Other Scale

  showIOS: function() {
    showSlide("iOSSlide");

    // setting up the iOS Slider. The bottom are parameters that I found via trial and error: feel free to edit them.
    iOSCanvas = Raphael('iOSDiv');
    LCircleEdge = 130;
    RCircleEdge = 350;
    circleYCoord = 125;
    LCircleColor = "#f90";
    RCircleColor = "#09f";
    iOSCircle1 = iOSCanvas.set();
    iOSCircle2 = iOSCanvas.set();

    iOSCircle1.push(iOSCanvas.circle(LCircleEdge, circleYCoord, 100).attr({ fill: LCircleColor,"stroke-width": 1,"fill-opacity": 0.4, stroke: "#000" } ));
    iOSCircle2.push(iOSCanvas.circle(RCircleEdge, circleYCoord, 100).attr({ fill: RCircleColor,"stroke-width": 1,"fill-opacity": 0.4, stroke: "#000" } ));

    //iOSCircle1.push(iOSCanvas.text(LCircleEdge-100, circleYCoord-100, "Self").attr({ fill: LCircleColor, "font-size": 24 })  );
    //iOSCircle2.push(iOSCanvas.text(RCircleEdge+100, circleYCoord-100, "Other").attr({ fill: RCircleColor, "font-size": 24 })  );
    iOSCircle1.push(iOSCanvas.text(LCircleEdge-100, circleYCoord-100, "You").attr({ fill: LCircleColor, "font-size": 24 })  );
    iOSCircle2.push(iOSCanvas.text(RCircleEdge+100, circleYCoord-100, experiment.characterName).attr({ fill: RCircleColor, "font-size": 24 })  );

    rotateSlider = mySliderFunction(iOSCanvas, LCircleEdge, circleYCoord+175, 'h200',"#AAAAAA", 15, iOSCircle1, iOSCircle2, LCircleEdge, RCircleEdge);
  },

  afterIOS: function() {
    experiment.iOS = rotateSlider.currentValue;

    experiment.end();
  },

/*
The function that gets called when the sequence is finished.
*/

  end: function() {
    // Show the finish slide.
    showSlide("finished");

    /*
    Wait 1.5 seconds and then submit the whole experiment object to Mechanical Turk (mmturkey filters out the functions so we know we’re just submitting properties [i.e. data])
    */
    setTimeout(function() { turk.submit(experiment);}, 1500);
  },

};


experiment.showIOS();
