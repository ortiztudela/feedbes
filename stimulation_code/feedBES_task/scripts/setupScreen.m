%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------


%% Set up screen properties
% ----------------------------------------------------------
'Setting up screen environment...'
% Close previos screens and textures
Screen('CloseAll');

% Check for timing and matlab version
Screen('Preference', 'SkipSyncTests', 1)
Screen('Preference', 'ConserveVRAM', 64);
Screen('Preference','TextRenderer',1);
AssertOpenGL;KbName('UnifyKeyNames');

% How many screens are available?
avail_screens=Screen('Screens');
if length(avail_screens)>1
    whichScreen=max(avail_screens-1); % Secondary monitor (BIC)
else
    whichScreen=avail_screens; %
end

% Open either test (small) or experiment (fullscreen) window
test_res = [40 40 1800 1000];
if testMode ==1
    [w, wRect]=Screen('OpenWindow',whichScreen, [128 128 128], test_res);  % Open small window
else
    [w, wRect]=Screen('OpenWindow',whichScreen, [128 128 128]);  % Open new full screen window and set up monitor, color and size
end
Screen('BlendFunction',w,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % Necesario para futuras funciones

% Set new window's priority as maximum
Priority(MaxPriority(w));

% Hide the mouse cursor
HideCursor;

% Get the Escape key code
escCode=KbName('Escape');

% Default text parameters
Screen('TextFont', w, 'Arial');                   % Font. Call listfonts para ver todos los disponibles
Screen('TextSize', w, 40);                       % Text size
Screen('TextColor', w, [255 255 255]);          % Color Visit https://www.w3schools.com/colors/colors_rgb.asp for color codes
Screen('TextStyle', w, 1);                        % Style (0=normal, 1=bold, 2=italic, 4=underline)

%% Returning gray values for mid-gray, white, and black
% ----------------------------------------------------------
gray=GrayIndex(w); white=WhiteIndex(w); black=BlackIndex(w);red=[255 0 0];

%% Assessing on-screen position
% ----------------------------------------------------------
% Load background image for obtaining image dimensions
temp=imread('stim/background.png');

% Get parameters
centerX=wRect(3)/2;centerY=wRect(4)/2;
sceneSizeX = size(temp,2);%centerX;
sceneSizeY = size(temp,1);%centerY;
if session == 3 || session == 5
    sceneSizeY = sceneSizeY*.75;
    sceneSizeX = sceneSizeX*.75;
end
clear temp;

% Define object size
objSizeX=400;objSizeY=200;
if session == 5 
    objSizeX=objSizeX*.75;objSizeY=objSizeY*.75;
end

% Define on-screen positions
scenePos = [centerX-(sceneSizeX/2), centerY-(sceneSizeY/2), centerX+(sceneSizeX/2), centerY+(sceneSizeY/2)];
patchPos = [centerX centerY centerX+sceneSizeX/2 centerY+sceneSizeY/2];
fixPos=[centerX-20 centerY-20 centerX+20 centerY+20];
objRect=[centerX+100 centerY+100 centerX+100+objSizeX centerY+100+objSizeY];
if session == 5
    objRect=[centerX+75 centerY+75 centerX+75+objSizeX centerY+75+objSizeY];
end
displ(1)=p.learn.displ*(objSizeX);displ(2)=p.learn.displ*(objSizeY);