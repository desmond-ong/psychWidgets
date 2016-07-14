/*
showSlide(id)
Displays each slide
*/

function showSlide(id) {
  $(".slide").hide();
  $("#"+id).show();
}

function resetSlider(sliderName) {
  sliderString = "#" + sliderName
  $(sliderString).css({"background":"#FFFFFF"});
  $(sliderString + " .ui-slider-handle").css({
        "background":"#FAFAFA",
        "border-color": "#CCCCCC" });
  $(sliderString + " .ui-slider-handle").hide();
}

/* Experimental Variables */
var numTrials = 2;

var numComplete = 0;

/*
Show the instructions slide — this is what we want subjects to see first.
*/
$("#progressBar").hide();
//showSlide("instructions");

// Updates the progress bar
$("#trial-num").html(numComplete);
$("#total-num").html(numTrials);


/*
The actual variable that will be returned to MTurk. The experiment object with various variables that you want to keep track of and return as results.

More practically, you should stick everything in an object and submit that whole object so that you don’t lose data (e.g. randomization parameters, what condition the subject is in, etc). Don’t worry about the fact that some of the object properties are functions — mmturkey (the Turk submission library) will strip these out.
*/

var experiment = {

  /*
  Parameters for this sequence.
  */
  startTime: 0,
  endTime: 0,

  // My Results:
  happyArray: new Array(numTrials),

  reactionTimeArray: new Array(numTrials),

  // Demographics
  comments:"",

  /*
  An array to store the data that we’re collecting.
  */

  // data: [],

  // Goes to description slide
  description: function() {
    showSlide("description");

    if (turk.previewMode) {
      alert ( "Please accept the HIT before continuing." );
    }
  },

/*
The function that gets called when the sequence is finished.
*/

  end: function() {
  	// Records demographics

    // Show the finish slide.
    showSlide("finished");

    /*
    Wait 1.5 seconds and then submit the whole experiment object to Mechanical Turk (mmturkey filters out the functions so we know we’re just submitting properties [i.e. data])
    */
    setTimeout(function() { turk.submit(experiment);}, 1500);
  },
  
  next: function() {
    showSlide("stage");
  
    if (numComplete == 0) { // First trial: initialize
      $("#progressBar").show();

      // setting up sliders
      $("#slider0").slider({
        // animate: true,
        max: 100 , min: 0, step: 1, value: 50,
        create: function( event, ui ) {
          $("#slider0 .ui-slider-handle").hide();
        },
        slide: function( event, ui ) {
          $("#slider0 .ui-slider-handle").show();
          $("#slider0 .ui-slider-handle").css({
            "background":"#E0F5FF",
            "border-color": "#001F29"
          });
        },
        change: function( event, ui ) {
          $('#hiddenSliderValue0').attr('value', ui.value);
          $("#slider0").css({"background":"#99D6EB"});
          $("#slider0 .ui-slider-handle").css({
            "background":"#667D94",
            "border-color": "#001F29" });
        }});
    }
    
    if (numComplete > 0) { // If this is not the first trial, record variables
      experiment.happyArray[numComplete-1] = parseInt($('#hiddenSliderValue0').val());
      
      resetSlider('slider0');
      $('#hiddenSliderValue0').val(undefined);
      
      experiment.endTime = (new Date()).getTime();
      experiment.reactionTimeArray[numComplete-1] = experiment.endTime - experiment.startTime;
    }
    
    if (numComplete >= numTrials) {
      // If subject has completed all trials, update progress bar and
      // show slide to ask for demographic info
      $('.bar').css('width', (200.0 * numComplete/numTrials) + 'px');
      $("#trial-num").html(numComplete);
      $("#total-num").html(numTrials);
      showSlide("askInfo");
    } else {
      // Otherwise, if trials not completed yet, update progress bar
      // and go to next trial based on the order in which trials are supposed
      // to occur
      $('.bar').css('width', (200.0 * numComplete/numTrials) + 'px');
      $("#trial-num").html(numComplete);
      $("#total-num").html(numTrials);
    
      experiment.startTime = (new Date()).getTime();
      numComplete++;
    } // end of else {}
  } // end of next()

};

experiment.next();