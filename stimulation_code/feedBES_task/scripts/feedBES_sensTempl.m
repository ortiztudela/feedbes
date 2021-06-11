%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
[nx, ny, bbox] = DrawFormattedText (w, '+',centerX,centerY, red); % Get size in pixels of the fixation
DrawFormattedText (w, 'Loading...','center',centerY-100, red);
Screen('Flip', w);

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
remainingT=p.sens.riseT-(FlipTimestamp-r.firstPulse);
collectResp(remainingT,escCode);

% Store run onset
r.runOnset=GetSecs;

% Collect a few volumes after the dummy
Screen('DrawTexture',w, blackTex, [],fixPos);
[~,~,FlipTimestamp,~,~,]=Screen('Flip', w);
remainingT=2-(FlipTimestamp-r.runOnset);
collectResp(remainingT,escCode);


%% Trial loop
for cTrial=1:p.sens.nTrials
    
    % Collect onset time
    r.trialOnset(cTrial)=GetSecs-r.runOnset;
    r.rt(cTrial)=0;r.resp(cTrial)=0;
    
    % Assess standard displacement
    trial_displ=[displ(1)*p.glob.stimMat{p.sens.expDes(cTrial),3},displ(2)*p.glob.stimMat{p.sens.expDes(cTrial),4}...
        displ(1)*p.glob.stimMat{p.sens.expDes(cTrial),3},displ(2)*p.glob.stimMat{p.sens.expDes(cTrial),4}];
    objRect_trial=objRect+trial_displ;
    r.stim_labels{cTrial}=p.sens.stim_labels{cTrial};
    r.obj_labels{cTrial}=p.sens.obj_labels{cTrial};
    
    % Display
    t1=GetSecs;
    Screen('DrawTexture',w, blank, [],scenePos);
    Screen('DrawTexture',w, stimTex(cTrial), [],scenePos);
    Screen('DrawTexture',w, objTexture(cTrial), [],objRect_trial);
    Screen('DrawTexture',w, redTex, [],fixPos);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    elapsedT=FlipTimestamp-t1;
    [r.resp(cTrial),r.rt(cTrial)]=collectResp(p.sens.trialDur-elapsedT,respKeys);%Remove stupid delay
    if r.resp(cTrial)==0
        r.rt(cTrial)=1.5;
    end
    remainingT=p.sens.trialDur-elapsedT-r.rt(cTrial);
    WaitSecs(remainingT);
    
    % Collect trial offset time
    r.trialOffset(cTrial)=GetSecs-r.runOnset;
    
    %% Start ITI period (ITI)
    % Collect ITI period onset time
    r.ITIOnset(cTrial)=GetSecs-r.runOnset;
    
    % Draw fixation
    Screen('DrawTexture',w, redTex, [],fixPos);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    
    % Wait a few milliseconds to account for processing delays
    elapsedT=FlipTimestamp-r.runOnset-r.ITIOnset(cTrial);
    collectResp(p.sens.ITIdur-elapsedT,escCode);
    
    % Collect ITIeriod offset time
    r.ITIOffset(cTrial)=GetSecs-r.runOnset;
    
end

% DieOut period
DrawFormattedText (w, ['This run has finished. You can close your eyes; \n\n '...
    'we will be done in a few seconds. Remember to try not to move.'] ,'center',centerY-100, red);
[~,~,FlipTimestamp,~,~,]=Screen('Flip', w);
remainingT=p.sens.dieOutT-(FlipTimestamp-r.runOnset);
WaitSecs(remainingT);

% Collect onset time
r.runOffset=GetSecs-r.runOnset;

% Save run info
save([p.paramName '_sens_data.mat'],'r')
