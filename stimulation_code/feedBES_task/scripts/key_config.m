%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Response keys configuration
% ----------------------------------------------------------
KbName('UnifyKeyNames');   % Unify key names across systems

if session == 1 || session == 7 || session == 6
    %%% Learning phase %%%
    % ----------------------------------------------------------

    respKeys(1)=KbName('A');respKeys(2)=KbName('L');
    choiceKeys=[KbName('1!');KbName('2@');KbName('3#');KbName('4$')];
    checkKeys=[KbName('leftarrow');KbName('uparrow');KbName('rightarrow');KbName('downarrow')];
    
elseif session == 2 || session == 3
    %%% Prediction phase %%%
    % ----------------------------------------------------------
    
    scannerKey=KbName('t');scannerKey(2)=KbName('5%');
    vividKeys(1)=KbName('1!');vividKeys(2)=KbName('2@');
    vividKeys(3)=KbName('3#');vividKeys(4)=KbName('4$');
    
elseif session == 4
    %%% Target mapping phase %%%
    % ----------------------------------------------------------
    
    scannerKey=KbName('t');scannerKey(2)=KbName('5%');
    respKeys=[KbName('1!');KbName('2@');KbName('3#');KbName('4$')];

elseif session == 5
    %%% Sensory template %%%
    % ----------------------------------------------------------
    
    scannerKey=KbName('t');scannerKey(2)=KbName('5%');
    respKeys=[KbName('1!');KbName('2@');KbName('3#');KbName('4$')];
    
    elseif session == 6
    %%% Postscan check %%%
    % ----------------------------------------------------------
    
    choiceKeys=[KbName('1!');KbName('2@');KbName('3#');KbName('4$')];
end