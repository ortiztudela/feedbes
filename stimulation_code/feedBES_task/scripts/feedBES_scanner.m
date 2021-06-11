%% Project: MEMORY-DRIVEN PREDICTIONS. Object generation task.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
[nx, ny, bbox] = DrawFormattedText (w, '+',centerX,centerY, red); %Get size in pixels of the fixation
DrawFormattedText (w, 'Loading...','center',centerY-100, red);
Screen('Flip', w);

%% Initialize important variables 

% Pre-allocate variables for speeding things up
r.trialOnset=zeros(p.pred.nTrials,1);r.trialOffset=zeros(p.pred.nTrials,1);
r.ITIOnset=zeros(p.pred.nTrials,1);r.ITIOffset=zeros(p.pred.nTrials,1);
r.runOnset=[];r.runOffset=[];
tecla=zeros(p.pred.nTrials,1);

%% Run starts here

% Start of run screen
DrawFormattedText(w, 'Waiting for scanner...','center','center',white);
Screen('Flip', w);

%Wait for scanner trigger
collectResp(-1,scannerKey);

% Store run onset
r.firstPulse=GetSecs;

% Rise period
Screen('DrawTexture',w, blackTex, [],fixPos);
[~,~,FlipTimestamp,~,~,]=Screen('Flip', w);
remainingT=p.pred.riseT-(FlipTimestamp-r.firstPulse);
collectResp(remainingT,escCode);

% Store run onset
r.runOnset=GetSecs;

% Collect a few volumes after the dummy
Screen('DrawTexture',w, blackTex, [],fixPos);
[~,~,FlipTimestamp,~,~,]=Screen('Flip', w);
remainingT=2-(FlipTimestamp-r.runOnset);
collectResp(remainingT,escCode);

%% Trial loop
for cTrial=1:length(p.pred.runMat)

    % Collect onset time
    r.trialOnset(cTrial)=GetSecs-r.runOnset;
%     r.current_map(cTrial)=p.pred.runMat(cTrial,3);
    
    %% Display stimulation at 5Hz
    for i=1:p.pred.stimDur*p.pred.flashFreq/2
        t1=GetSecs;
        % Check for ESCAPE
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        if keyCode(escCode)==1
            Screen('CloseAll');
            error('Aborted by user')
        end
        
        % Scene
        Screen('DrawTexture',w, blank, [],scenePos);
        Screen('DrawTexture',w, sel_tex(cTrial), [],scenePos);
        Screen('DrawTexture',w, patch, [],scenePos);
        Screen('DrawTexture',w, redTex, [],fixPos);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        elapsedT=FlipTimestamp-t1;
        WaitSecs((p.pred.duration)-elapsedT); %Remove stupid delay
        
        %Blank
        t1=GetSecs;
        Screen('DrawTexture',w, blank, [],scenePos);
        Screen('DrawTexture',w, patch, [],scenePos);
        Screen('DrawTexture',w, redTex, [],fixPos);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        elapsedT=FlipTimestamp-t1;
        WaitSecs((p.pred.duration)-elapsedT); %Remove stupid delay
    end
    
    % Collect trial offset time
    r.trialOffset(cTrial)=GetSecs-r.runOnset;

    %% Start ITI period (ITI)
    % Collect ITI period onset time
    r.ITIOnset(cTrial)=GetSecs-r.runOnset;
    Screen('Flip', w);
    WaitSecs(1.5);
    
    % Draw vividness feedback
    Screen('DrawTexture',w, redTex, [],fixPos);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    elapsedT=FlipTimestamp-r.runOnset-r.ITIOnset(cTrial);
    WaitSecs(p.pred.ITIdur-elapsedT);

    % Collect ITIeriod offset time
    r.ITIOffset(cTrial)=GetSecs-r.runOnset;
    
end

% Collect onset time
r.runOffset=GetSecs-r.runOnset;

% DieOut period
DrawFormattedText (w, ['This run has finished. You can close your eyes; \n\n '...
    'we will be done in a few seconds. Remember to try not to move.'] ,'center',centerY-100, white);
Screen('Flip', w);
WaitSecs(p.pred.dieOutT);

% Save run info
save([p.paramName '_run' num2str(cRun) '_data.mat'],'r')
