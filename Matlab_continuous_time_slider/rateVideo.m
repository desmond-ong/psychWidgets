function rateVideo( participantID, storyNames )
% rateVideo 
%
% written by Desmond Ong (desmond.c.ong at gmail). 
%   github.com/desmond-ong
% this version: 16 August, 2016
%
% Prerequisites: 
%    Matlab (duh)
%    Psychtoolbox
%    gstreamer (required by Psychtoolbox for multimedia on windows)
%
%
% This function plays the videos and allows the participants to rate the videos while watching it.
%
% Currently, it collects ratings every TIME_INTERVAL seconds, and outputs
% the file to outputDirectory/XXX/XXX_vidY_ratings.csv
%     where XXX is the participantID and Y is the trial or video number
% this is in following line:
%     trialOutputFile = ['data/' num2str(participantID) '/ID' num2str(participantID) '_vid' num2str(iTrial) '_ratings.csv'];
%
% the input movies are assumed to be of the form:
%     videoDirectory/IDXXX_vidY.mp4
%     where XXX is the particpnatID and Y is the trial or video number
% this is in following line:
%     movieName = [videoDirectory 'ID' num2str(participantID) '_vid' num2str(iTrial) '.mp4'];
%
% input
%   participantID: assumed to be some numeric ID. (alphanumeric might work, but I haven't tested.)
%   storyNames: a Nx1 cell where the j-th cell contains the title of the j-th video.
%       i.e., storyNames{j} is a string that contains the title of the j-th video.
%
% key parameters:
%   TIME_INTERVAL: interval between ratings / sampling rate (currently, 0.5s)
%
%
%
% other "parameters"
%
%   numTrials: how many videos (assumed to be length(storyNames)).
%
%   videoDirectory: where the video files are stored
%   outputDirectory: where the output (ratings) data will be written to
%
%   mouseButtonToMoveOnwards: which mouse button to proceed with the experiment
%
%


    
    TIME_INTERVAL = 0.5; % get ratings every 0.5 seconds

    numTrials = length(storyNames);

% edit to point to your directory. Note that PC would use \ while Mac and Unix would use /
% as file separators.
videoDirectory = '/Users/.../Documents/.../';

outputDirectory = 'data/';

% assuming you have a mouse with left + right + mousewheel, I found that, at least for my computers,
% on a PC the left button is 1, and the right mouse button is 3. (mouse wheel is 2)
% on a Mac, the left button is 1, and the right mouse button is 2.
% you may need to change this depending on your OS and particular mouse.
mouseButtonToMoveOnwards = 2; 



    % ----- Preamble: defining variables, etc ----- %

    % Different operating systems use different names for the keys on the
    % keyboard. This function switches the namespace to the OSX names, for
    % cross-platform portability.
    KbName('UnifyKeyNames');

    % shortcuts for keycodes 
    escapeKey = KbName('ESCAPE');
    rKey = KbName('r');
    sKey = KbName('s');
    rightKey = KbName('RIGHTARROW');
    leftKey = KbName('LEFTARROW');
    enterKey = KbName('Return');
    spaceKey = KbName('SPACE');
    
    


    
    
    % For an explanation of the try-catch block, see the section "Error Handling"
    % at the end of this document.
    try
        % ---------- Window Setup ----------
        % Opens a window.

        AssertOpenGL;

        % Prevents MATLAB from reprinting the source code when the program runs.
        echo off
        % ListenChar(2) disables keyboard input to other windows. ListenChar(0) re-enables.
        ListenChar(2) 
        
        % Screen is able to do a lot of configuration and performance checks on
        % open, and will print out a fair amount of detailed information when
        % it does.  These commands supress that checking behavior and just let
        % the demo go straight into action.  See ScreenTest for an example of
        % how to do detailed checking.
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
        oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
	
        % Find out how many screens and use largest screen number.
        whichScreen = max(Screen('Screens'));
    
        % Hides the mouse cursor
        %HideCursor;
        
        % Opens a graphics window on the monitor.
        % should I standardize 800x600? Screen('Resolution', screenNumber, 800, 600);
        windowPtr = Screen('OpenWindow', whichScreen);
        
        
        % getting the width and height of the window, in pixels
        [screenWidth, screenHeight]=Screen('WindowSize', whichScreen);
        
        
        % ---------- Color Setup ----------
        % Gets color values.

        % Retrieves color codes for black and white and gray.
        black = BlackIndex(windowPtr);  % Retrieves the CLUT color code for black.
        white = WhiteIndex(windowPtr);  % Retrieves the CLUT color code for white.
        grey = (black+white)/2;
        lightGrey = (white+grey)/2;
        
        
        % ---------- Image Display ---------- 
        % Colors the entire window white
        Screen('FillRect', windowPtr, white);
        %Screen('PutImage', windowPtr, (FixationCross));
        
        Screen(windowPtr, 'TextFont', 'Helvetica');
        Screen(windowPtr, 'TextSize', 20);
        
        
        
        % --------- Defining Variables ---------
        % Defining the size of the slider and handles
        sliderLeftEnd = screenWidth/2 - 300;
        sliderRightEnd = screenWidth/2 + 300;
        sliderTopEnd = 770;
        sliderBottomEnd = 790;
        
        sliderHandleHalfWidth = 20;
        sliderHandleTop = sliderTopEnd-5;
        sliderHandleBottom = sliderBottomEnd+5;
        
        % defining the top edge of the movie window
        movieTopEnd = 150;
        
        % defining where the text starts
        TEXT_LEFT_START = 50;
        
        
        
        % Writes Instruction Text to the window.
        currentTextRow = 80;
        
        instructionsText1 = 'In this part of the study, you will be watching several videos.';
        
        instructionsText2 = 'While watching these videos, we would like you to rate XXX.';
        %instructionsText2b = ' ... ';
        %instructionsText3 = ' ... ';
        %instructionsText4 = ' ... ';
        %        
        instructionsText5 = 'Please make your ratings using the slider below the video.';
        instructionsText6 = 'Whenever you want to change your rating, simply hold down the left mouse button and move the mouse to move the slider to wherever you like.';
        instructionsText7 = 'Far left indicates "Very negative", and far right indicates "Very positive".';
    
        instructionsText8 = 'Try making using the rating scale below. Hold down the left mouse button and move the mouse to move the slider.';
        instructionsText9 = 'You do not have to hold down the button for the whole time, but the rating scale will only move when the left mouse button is held down.';
        instructionsText10 = 'Put on your headphones, and press the right mouse button when you are done.';
        
        Screen('DrawText', windowPtr, sprintf(instructionsText1), TEXT_LEFT_START, currentTextRow, black);
        currentTextRow = currentTextRow + 40;
        Screen('DrawText', windowPtr, sprintf(instructionsText2), TEXT_LEFT_START, currentTextRow, black);            
        currentTextRow = currentTextRow + 40;
    	%Screen('DrawText', windowPtr, sprintf(instructionsText2b), TEXT_LEFT_START, currentTextRow, black);            
        %currentTextRow = currentTextRow + 40;
    	%Screen('DrawText', windowPtr, sprintf(instructionsText3), TEXT_LEFT_START, currentTextRow, black);
        %currentTextRow = currentTextRow + 40;
        %Screen('DrawText', windowPtr, sprintf(instructionsText4), TEXT_LEFT_START, currentTextRow, black);
        %currentTextRow = currentTextRow + 40;
        
        currentTextRow = currentTextRow + 40;
        
    	Screen('DrawText', windowPtr, sprintf(instructionsText5), TEXT_LEFT_START, currentTextRow, black);
        currentTextRow = currentTextRow + 40;
        Screen('DrawText', windowPtr, sprintf(instructionsText6), TEXT_LEFT_START, currentTextRow, black);
        currentTextRow = currentTextRow + 40;
    	Screen('DrawText', windowPtr, sprintf(instructionsText7), TEXT_LEFT_START, currentTextRow, black);
        currentTextRow = currentTextRow + 40;
        
        currentTextRow = currentTextRow + 40;
        
    	Screen('DrawText', windowPtr, sprintf(instructionsText8), TEXT_LEFT_START, currentTextRow, black);    
        currentTextRow = currentTextRow + 40;
    	Screen('DrawText', windowPtr, sprintf(instructionsText9), TEXT_LEFT_START, currentTextRow, black);
        currentTextRow = currentTextRow + 40;
    	Screen('DrawText', windowPtr, sprintf(instructionsText10), TEXT_LEFT_START, currentTextRow, black);
    
        
        
	 
        
        
        % Drawing the slider
        % rectangle coordinates are [Left Top Right Bottom]
        % Create the slider and the end labels
        Screen('FillRect', windowPtr, grey, [sliderLeftEnd sliderTopEnd sliderRightEnd sliderBottomEnd]);
        Screen('DrawText', windowPtr, sprintf('Very Negative'), (sliderLeftEnd-60), (sliderTopEnd-40), black);
        Screen('DrawText', windowPtr, sprintf('Very Positive'), (sliderRightEnd-60), (sliderTopEnd-40), black);
        
        
        
        % Create and draw the slider handle
        sliderHandlePosition = screenWidth/2;
        sliderHandleLeft = sliderHandlePosition - sliderHandleHalfWidth;
        sliderHandleRight = sliderHandlePosition + sliderHandleHalfWidth;
        Screen('FillRect', windowPtr, lightGrey, [sliderHandleLeft sliderHandleTop sliderHandleRight sliderHandleBottom]);
        
        
        
        % Updates the screen to reflect our changes to the window.
        Screen('Flip', windowPtr);
        
        % Always call Screen Flip to draw buffer to screen!! Call it before
        % waiting!
        

        finishInstructions = 0;
        while ~finishInstructions
            [mouseX, mouseY, mouseButtons] = GetMouse;
            %while any(mouseButtons) % if already down, wait for release
            %    [mouseX, mouseY, mouseButtons] = GetMouse;
            %end
            %while ~any(mouseButtons) % wait for press
            %    [mouseX, mouseY, mouseButtons] = GetMouse;
            %    oldMouseX = mouseX;
            %end
            if mouseButtons(mouseButtonToMoveOnwards)
                % right button is pressed down
                % quit this loop
                finishInstructions = 1;
                break
            end
            
            if mouseButtons(1) % left mouse button is held down
                %[mouseX, mouseY, mouseButtons] = GetMouse;
                if mouseX ~= oldMouseX
                    
                    % Writes Instruction Text to the window.
                    currentTextRow = 80;
                    Screen('DrawText', windowPtr, sprintf(instructionsText1), TEXT_LEFT_START, currentTextRow, black);
                    currentTextRow = currentTextRow + 40;
                    Screen('DrawText', windowPtr, sprintf(instructionsText2), TEXT_LEFT_START, currentTextRow, black);            
                    currentTextRow = currentTextRow + 40;
                    %Screen('DrawText', windowPtr, sprintf(instructionsText2b), TEXT_LEFT_START, currentTextRow, black);            
                    %currentTextRow = currentTextRow + 40;
                    %Screen('DrawText', windowPtr, sprintf(instructionsText3), TEXT_LEFT_START, currentTextRow, black);
                    %currentTextRow = currentTextRow + 40;
                    %Screen('DrawText', windowPtr, sprintf(instructionsText4), TEXT_LEFT_START, currentTextRow, black);
                    %currentTextRow = currentTextRow + 40;

                    currentTextRow = currentTextRow + 40;

                    Screen('DrawText', windowPtr, sprintf(instructionsText5), TEXT_LEFT_START, currentTextRow, black);
                    currentTextRow = currentTextRow + 40;
                    Screen('DrawText', windowPtr, sprintf(instructionsText6), TEXT_LEFT_START, currentTextRow, black);
                    currentTextRow = currentTextRow + 40;
                    Screen('DrawText', windowPtr, sprintf(instructionsText7), TEXT_LEFT_START, currentTextRow, black);
                    currentTextRow = currentTextRow + 40;

                    currentTextRow = currentTextRow + 40;

                    Screen('DrawText', windowPtr, sprintf(instructionsText8), TEXT_LEFT_START, currentTextRow, black);    
                    currentTextRow = currentTextRow + 40;
                    Screen('DrawText', windowPtr, sprintf(instructionsText9), TEXT_LEFT_START, currentTextRow, black);
                    currentTextRow = currentTextRow + 40;
                    Screen('DrawText', windowPtr, sprintf(instructionsText10), TEXT_LEFT_START, currentTextRow, black);

                    
                    
                    % Drawing the slider
                    Screen('FillRect', windowPtr, grey, [sliderLeftEnd sliderTopEnd sliderRightEnd sliderBottomEnd]);
                    Screen('DrawText', windowPtr, sprintf('Very Negative'), (sliderLeftEnd-60), (sliderTopEnd-40), black);
                    Screen('DrawText', windowPtr, sprintf('Very Positive'), (sliderRightEnd-60), (sliderTopEnd-40), black);


                    sliderHandlePosition = sliderHandlePosition + (mouseX - oldMouseX);
                    sliderHandlePosition = max(sliderLeftEnd, min(sliderRightEnd, sliderHandlePosition));
                    sliderHandleLeft = sliderHandlePosition - sliderHandleHalfWidth;
                    sliderHandleRight = sliderHandlePosition + sliderHandleHalfWidth;
                    Screen('FillRect', windowPtr, lightGrey, [sliderHandleLeft sliderHandleTop sliderHandleRight sliderHandleBottom]);

                    %Screen('DrawText', windowPtr, sprintf('xPosition: %d', sliderHandlePosition), TEXT_LEFT_START, currentTextRow + 40, black);
                    sliderValue = (sliderHandlePosition - sliderLeftEnd) / (sliderRightEnd - sliderLeftEnd) * 100;
                    %Screen('DrawText', windowPtr, sprintf('slider value: %d', sliderValue), TEXT_LEFT_START, currentTextRow + 80, black);

                    Screen(windowPtr, 'Flip');
                end
                %oldMouseX = mouseX;
            end % end left mouse button held down if loop
            oldMouseX = mouseX;
        end

        while any(mouseButtons) % wait for previous mouse button to be released
            [mouseX, mouseY, mouseButtons] = GetMouse;
        end

        
        

        %%% done with instructions right now.
        
        % ---------- Key Input -----------

        %while 1
        %    [ keyIsDown, timeSecs, keyCode ] = KbCheck;
        %    if keyIsDown
        %        break;
        %    end
        %end
        
        
        
        % exitFlag is a boolean to keep going. so if exitFlag == 1, program exits.
        exitFlag = 0;
        
        % start for loop over trials here
        for iTrial = 1:numTrials
            
            movieName = [videoDirectory 'ID' num2str(participantID) '_vid' num2str(iTrial) '.mp4'];
            
            % Open the moviefile and query some infos like duration, framerate,
            % width and height of video frames:
            [moviePointer movieDuration movieFps fullMovieWidth fullMovieHeight movie_framecount] = Screen('OpenMovie', windowPtr, movieName);
            % We estimate framecount instead of querying it - faster:
            framecount = movieDuration * movieFps;
        
            SHRINK_FACTOR = 2;
            movieWidth = fullMovieWidth / SHRINK_FACTOR;
            movieHeight = fullMovieHeight / SHRINK_FACTOR;
            
            movieLeftEnd = (screenWidth - movieWidth)/2;
            movieRightEnd = (screenWidth + movieWidth)/2;
            movieBottomEnd = movieTopEnd + movieHeight;    
            
            // if ispc
            //     trialOutputFile = ['data\' num2str(participantID) '\ID' num2str(participantID) '_vid' num2str(iTrial) '_ratings.csv'];
            // else
            trialOutputFile = ['data/' num2str(participantID) '/ID' num2str(participantID) '_vid' num2str(iTrial) '_ratings.csv'];
            // end
            
            fid = fopen(trialOutputFile, 'w');
            fprintf(fid, 'time, rating\n');
            fclose(fid);
            
            MAX_INTERVALS = round(movieDuration / TIME_INTERVAL) + 2;
            ratings = zeros(MAX_INTERVALS, 2);
        
            if exitFlag == 1
                fprintf('Program exited after %d trials.\n', iTrial);
                break;
            end
            
            % reset slider handle to center of slider
            sliderHandlePosition = screenWidth/2;
            sliderValue = (sliderHandlePosition - sliderLeftEnd) / (sliderRightEnd - sliderLeftEnd) * 100;
            

            currentTextRow = 50;
            if iTrial>1
            Screen('DrawText', windowPtr, sprintf('Done with event number: %d', iTrial-1), TEXT_LEFT_START, currentTextRow, black);
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('Next: video number: %d', iTrial), screenWidth/2 - 50, currentTextRow, black);
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('%s', storyNames{iTrial}), screenWidth/2 - 50, currentTextRow, black);
            else
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('Video Number: %d', iTrial), screenWidth/2 - 50, currentTextRow, black);
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('%s', storyNames{iTrial}), screenWidth/2 - 50, currentTextRow, black);
            end
            
            currentTextRow = currentTextRow + 40;
            
            Screen('DrawText', windowPtr, sprintf('Press the right mouse button to start the movie'), TEXT_LEFT_START, currentTextRow, black);
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('Once the movie has started, remember to make your ratings throughout the video '), TEXT_LEFT_START, currentTextRow, black);
            currentTextRow = currentTextRow + 40;
            Screen('DrawText', windowPtr, sprintf('by holding the left mouse button and moving the mouse.'), TEXT_LEFT_START, currentTextRow, black);
            
            
            
            % Drawing the slider
            Screen('FillRect', windowPtr, grey, [sliderLeftEnd sliderTopEnd sliderRightEnd sliderBottomEnd]);
            Screen('DrawText', windowPtr, sprintf('Very Negative'), (sliderLeftEnd-60), (sliderTopEnd-40), black);
            Screen('DrawText', windowPtr, sprintf('Very Positive'), (sliderRightEnd-60), (sliderTopEnd-40), black);

            sliderHandleLeft = sliderHandlePosition - sliderHandleHalfWidth;
            sliderHandleRight = sliderHandlePosition + sliderHandleHalfWidth;
            Screen('FillRect', windowPtr, lightGrey, [sliderHandleLeft sliderHandleTop sliderHandleRight sliderHandleBottom]);
            
            
            Screen(windowPtr, 'Flip');
            
            
                
            movieStarted = 0;
            movieFinished = 0;
            readyToMoveToNext = 0;
            
            while movieStarted ~= 1
                [mouseX, mouseY, mouseButtons] = GetMouse;
                
                if mouseButtons(mouseButtonToMoveOnwards)
                    % right button is pressed down
                    % quit this loop
                    while any(mouseButtons) % wait for previous mouse button to be released
                        [mouseX, mouseY, mouseButtons] = GetMouse;
                    end
        
                    movieStarted = 1;
                    timeAtMovieStart = GetSecs;
                    timeAtLastInterval = timeAtMovieStart;
                    currentIntervalNumber = 1;

                    % Screen('PlayMovie', moviePtr, rate, [loop], [soundvolume]);
                    % Play the movie, rate = 1 (normal speed forward), loop = 0 (play movie just once), 1.0 = 100% volume
                    Screen('PlayMovie', moviePointer, 1, 0, 1.0); 
                end
            end
            
                        
            % for loop over time?
            while movieFinished ~= 1 % change this to a for loop over time
                
                % Writes Instruction Text to the windowPtr.
                currentTextRow = 80;
                Screen('DrawText', windowPtr, sprintf('Make your ratings throughout the video by holding the left mouse button and moving the mouse.'), TEXT_LEFT_START, currentTextRow, black);                    

                % Drawing the slider
                Screen('FillRect', windowPtr, grey, [sliderLeftEnd sliderTopEnd sliderRightEnd sliderBottomEnd]);
                Screen('DrawText', windowPtr, sprintf('Very Negative'), (sliderLeftEnd-60), (sliderTopEnd-40), black);
                Screen('DrawText', windowPtr, sprintf('Very Positive'), (sliderRightEnd-60), (sliderTopEnd-40), black);

                Screen('FillRect', windowPtr, lightGrey, [sliderHandleLeft sliderHandleTop sliderHandleRight sliderHandleBottom]);
                sliderValue = (sliderHandlePosition - sliderLeftEnd) / (sliderRightEnd - sliderLeftEnd) * 100;

                
                timeNow = GetSecs;
                if (timeNow - timeAtLastInterval) > TIME_INTERVAL && currentIntervalNumber < MAX_INTERVALS
                    
                    ratings(currentIntervalNumber, :) = [timeNow-timeAtMovieStart, sliderValue];
                    dlmwrite(trialOutputFile, ratings(currentIntervalNumber, :), '-append'); 
                    
                    timeAtLastInterval = timeNow;
                    currentIntervalNumber = currentIntervalNumber + 1;
                    if currentIntervalNumber == MAX_INTERVALS
                        movieFinished = 1;
                        break
                    end
                end
            

                [mouseX, mouseY, mouseButtons] = GetMouse;

%                   if mouseButtons(mouseButtonToMoveOnwards)
%                       % right button is held down
%                       % quit this loop
%                       movieFinished = 1;
%                       break
%                   end
                % wait for release

                if mouseButtons(1) % left mouse button is held down

                    if mouseX ~= oldMouseX
                        % Writes Instruction Text to the windowPtr.
                        %Screen('DrawText', windowPtr, sprintf('Remember to make your ratings throughout the video by holding the left mouse button and moving the mouse.'), TEXT_LEFT_START, 80, black);                    
                    
                        % Drawing the slider
                        %Screen('FillRect', windowPtr, grey, [sliderLeftEnd sliderTopEnd sliderRightEnd sliderBottomEnd]);
                        %Screen('DrawText', windowPtr, sprintf('Very Negative'), (sliderLeftEnd-60), (sliderTopEnd-40), black);
                        %Screen('DrawText', windowPtr, sprintf('Very Positive'), (sliderRightEnd-60), (sliderTopEnd-40), black);


                        sliderHandlePosition = sliderHandlePosition + (mouseX - oldMouseX);
                        sliderHandlePosition = max(sliderLeftEnd, min(sliderRightEnd, sliderHandlePosition));
                        sliderHandleLeft = sliderHandlePosition - sliderHandleHalfWidth;
                        sliderHandleRight = sliderHandlePosition + sliderHandleHalfWidth;
                        %Screen('FillRect', windowPtr, lightGrey, [sliderHandleLeft sliderHandleTop sliderHandleRight sliderHandleBottom]);

                        %Screen('DrawText', windowPtr, sprintf('xPosition: %d', sliderHandlePosition), TEXT_LEFT_START, currentTextRow + 40, black);
                        sliderValue = (sliderHandlePosition - sliderLeftEnd) / (sliderRightEnd - sliderLeftEnd) * 100;
                        %Screen('DrawText', windowPtr, sprintf('slider value: %d', sliderValue), TEXT_LEFT_START, currentTextRow + 80, black);

                        %Screen(windowPtr, 'Flip');
                    end
                    %oldMouseX = mouseX;
                end % end left mouse button held down if loop
                oldMouseX = mouseX;
                
                
                % Wait for next movie frame, retrieve texture handle to it
                textureHandle = Screen('GetMovieImage', windowPtr, moviePointer);

                % Valid texture returned? A negative value means end of movie reached:
                if textureHandle<=0
                    % We're done, break out of loop:
                    movieFinished = 1;
                    break;
                end
                
                % Draw the new texture immediately to screen:
                Screen('DrawTexture', windowPtr, textureHandle, [0 0 fullMovieWidth fullMovieHeight], [movieLeftEnd movieTopEnd movieRightEnd movieBottomEnd]);
                
                Screen(windowPtr, 'Flip');
                
                % Release texture:
                Screen('Close', textureHandle);
                
            end % end of for loop over time
            
            
            % Close movie:
            Screen('CloseMovie', moviePointer);
            clear moviePointer
            Screen(windowPtr, 'Flip');
            
            while any(mouseButtons) % wait for previous mouse button to be released
                [mouseX, mouseY, mouseButtons] = GetMouse;
            end
            
            
        end % end for loop over trials here
        
        currentTextRow = 50;
            
        Screen('DrawText', windowPtr, sprintf('Done with last event! Press the right mouse button to end'), TEXT_LEFT_START, currentTextRow, black);
        Screen(windowPtr, 'Flip');

        while readyToMoveToNext ~= 1
            [mouseX, mouseY, mouseButtons] = GetMouse;
                
            if mouseButtons(mouseButtonToMoveOnwards)
                % right button is pressed down
                % quit this loop
                readyToMoveToNext = 1;
            end
        end
        
        % ---------- Window Cleanup ---------- 

        % Closes all windows.
        Screen('CloseAll');
	 
        % Restores the mouse cursor.
        ShowCursor;
        
        % Restores the keyboard
        ListenChar(0);

        % Restore preferences
        Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
        Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
        
    catch
        % ---------- Error Handling ---------- 
        % If there is an error in our code, we will end up here.
        
        % The try-catch block ensures that Screen will restore the display and return us
        % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
        % block, Screen could still have control of the display when MATLAB throws an error, in
        % which case the user will not see the MATLAB prompt.
        Screen('CloseAll');
        
        % Restores the mouse cursor.
        ShowCursor;
    
        % Restores the keyboard
        ListenChar(0);
        
        % Restore preferences
        Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
        Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

        % We throw the error again so the user sees the error description.
        psychrethrow(psychlasterror);
        return;
    end;



end

