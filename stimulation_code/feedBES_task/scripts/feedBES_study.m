%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
Screen('DrawTexture',w, blackTex, [],fixPos);
Screen('Flip', w);
WaitSecs(p.learn.fixTime);

%% Run starts here
% Initialize variables for storage
Screen('TextSize', w, 50);                       % Text size

%% Display pairs
% Collect onset time
r.pairsOnset=GetSecs;
for cCycle=1:p.learn.nCycles

    % Start of run screen
    DrawFormattedText(w, 'Are you ready to start a learning block?','center','center',white);
    WaitSecs(.2);
    Screen('Flip', w);
    KbWait;

    % Generate a random sequence for this loop of the repetition
    randOrd=randperm(p.learn.nTrials);
    
    % Store order
    r.storedOrder(cCycle,:)=randOrd;
    p.glob.stimMat
    % Loop through pairs
    for cPairs=1:p.learn.nTrials
        
        % Stim labels
        r.learn.scn_names{cPairs,cCycle}=p.glob.scn_names{randOrd(cPairs)};
        r.learn.obj_names{cPairs,cCycle}=p.glob.obj_names{randOrd(cPairs)};
        
        % Assess standard displacement
        trial_displ=[displ(1)*p.glob.stimMat{randOrd(cPairs),3},displ(2)*p.glob.stimMat{randOrd(cPairs),4}...
            displ(1)*p.glob.stimMat{randOrd(cPairs),3},displ(2)*p.glob.stimMat{randOrd(cPairs),4}];
        objRect_trial=objRect+trial_displ;
        
        % Display
        t1=GetSecs;
        Screen('DrawTexture',w, blank, [], scenePos);
        Screen('DrawTexture',w, scnTex(randOrd(cPairs)), [], scenePos);
        Screen('DrawTexture', w, objTex(randOrd(cPairs)) ,[], objRect_trial);
        Screen('DrawTexture',w, redTex, [],fixPos);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        WaitSecs(.2);
        elpasedT=FlipTimestamp-t1;
        collectResp(p.learn.trialDur-elpasedT,respKeys);
        
        % Fix
        Screen('DrawTexture',w, blackTex, [],fixPos);
        Screen('Flip', w);
        WaitSecs(1);
    end
    
    % Run test
    run feedBES_study_test.m
    
end
% Collect block offset time
r.pairsOffset=GetSecs-r.pairsOnset;

%% DieOut period
DrawFormattedText(w, 'Well done! \n\n Let the experimenter know you have finished','center',centerY-25,white);
WaitSecs(.2)
Screen('Flip', w);
KbWait;

% Save run info
save([p.paramName '_learn_data.mat'],'r')

% Echo permformance to command window�
['Object acc = ', num2str(mean(r.study_object_acc(:,end)))]
['Position acc = ', num2str(mean(r.study_position_acc(:,end)))]