%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Welcome screen
Screen('TextSize', w, 20);                       % Text size

%Load lab logo.
logo=Screen('MakeTexture', w,imread('scripts/LISCOlogo.png'));
Screen('DrawTexture', w, logo,[],[centerX-centerX*.25 centerY-centerY*.8 centerX+centerX*.25 centerY])
DrawFormattedText(w, 'Welcome!','center',centerY+centerY*.1,white);
Screen('Flip', w);
WaitSecs(.5);

%Check for key press
KbWait;
WaitSecs(0.2);

%% Instructions

% Start of run screen
if session == 1
    Screen('TextSize', w, 15);                       % Text size
    
    DrawFormattedText(w, ['Today you will have to study a few images.\n\n',...
        'The images will depict 8 different locations of an imaginary city. \n\n',...
        'These four objects have been dispersed across all the locations in our city. \n\n',...
        'Your task is to try to remember the location of each object. \n\n',...
        'Beware! The objects might be present in more than one location. \n\n',...
        'You will see every scene ten times, so you will have plenty of time \n\n',...
        'to memorize it. It is important that you \n\n',...
        'try to remember as many details as possible since later on we will \n\n',...
        'ask you to draw some parts of the scene in a sheet of paper. \n\n\n\n\n',...
        'If you have any question, ask the experimenter. '],'centerblock','center',white);
    Screen('DrawTexture', w, objTex(1) ,[], ...
        [centerX*.2 centerY*.2 centerX*.7 centerY*.7]);
    Screen('DrawTexture', w, objTex(2) ,[], ...
        [centerX*.2 centerY*1.2 centerX*.7 centerY*1.7]);
    Screen('DrawTexture', w, objTex(3) ,[], ...
        [centerX*1.2 centerY*.2 centerX*1.7 centerY*.7]);
    Screen('DrawTexture', w, objTex(4) ,[], ...
        [centerX*1.2 centerY*1.2 centerX*1.7 centerY*1.7]);
    
elseif session == 2
    Screen('TextSize', w, 20);                       % Text size
    
    DrawFormattedText(w, ['Now we will do a short training for tomorrows session.\n\n',...
        'You will see the scenes that you have studied before but with the white patch \n\n',...
        'located on the bottom right part of the screen. \n\n',...
        'Your task is to think back to the object associated with this ',...
        'particular scene, and visualize it as vividly as possible in \n\n',...
        'your mind for the full duration of the trial. \n\n',...
        'Right after the scene has dissapear you will need to \n\n',...
        'tell us how vivid your mental image was using a 4 points scale with: \n\n\n',...
        '1 = I was unable to retrieve the object that fits the scene, \n\n',...
        '2 = I retrieved the object but I could not visualize it, \n\n',...
        '3 = I have visualized the object with a few details, \n\n',...
        '4 = I have visualized the object with a lot of details \n\n\n',...
        'Remember to keep your eyes fixed at the fixation cross when it is present; \n\n',...
        'this will help you visualize the object in its appropriate position in the scene. \n\n\n',...
        'If you have any question, ask the experimenter. '],'centerblock','center',white);
    
elseif  session == 3
    
    Screen('TextSize', w, 20);                       % Text size
    
    DrawFormattedText(w, ['In a few seconds the remembering block will start.\n\n\n\n',...
        'You will see the scenes that you studied yesterday and also the new ones from today.\n\n\n',...
        'Remember to not move the eyes from the center since \n\n',...
        'it will help you bring back to mind the entire scene with the object in its place. \n\n\n',...
        'Remember to try to create images as vivid as possible. \n\n\n',...
        'If you have any question, ask the experimenter. '],'centerblock','center',white);

elseif  session == 4
    
    Screen('TextSize', w, 20);                       % Text size
    
    DrawFormattedText(w, ['In a few seconds we will start the first checkerboard block.\n\n\n\n',...
        'Remember that you have to keep your eyes on the fixation cross at all times.\n\n\n',...
        'Your task will be to press the button and hold it when the \n\n',...
        'fixation cross turns green. You will have to quickly release the button \n\n',...
        'as soon as the cross turns back to red. \n\n\n',...
        'This block will last about 7 minutes. '],'centerblock','center',white);
    
elseif  session == 5
    
    Screen('TextSize', w, 20);                       % Text size
    
    DrawFormattedText(w, ['In a few seconds we will start the solutions block.\n\n\n\n',...
        'In this block we will show you the scenes with the objects.\n\n\n',...
        'Your task is to look for adyacent repetitions in the stream of trials.\n\n',...
        'Everytime that you see that the same object repeats twice in a row, \n\n\n',...
        'you must press the button. REMEMBER: only if the two repetitions are together. \n\n\n\n\n',...
        'Finally, remember that you must keep your eyes at the fixation cross at all times. \n\n\n',...
        'This block will last about 7 minutes. '],'centerblock','center',white);
    
    
end
WaitSecs(.2);
Screen('Flip', w);
KbWait;
