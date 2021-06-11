%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
Screen('DrawTexture',w, blackTex, [],fixPos);
Screen('Flip', w);
WaitSecs(p.learn.fixTime);

%% Run starts here
% Initialize variables for storage
r.pred.testStim=p.glob.stimMat(randperm(p.learn.nTrials)+8,:);
acc=0;
Screen('TextSize', w, 50);                       % Text size

% Start of run screen
DrawFormattedText(w, 'Are you ready? Press any key to start',...
    'center','center',white);
WaitSecs(.2);
Screen('Flip', w);
KbWait;

% Create object textures
obj_uniq=unique(r.pred.testStim(:,2));
for cObj=1:4
    [temp,~,alpha]=imread(['stim/',obj_uniq{cObj},'.png']);
    obj_tex(cObj)=Screen('MakeTexture',w,cat(3,temp,alpha));
end

%% Test for episodic
cCycle=7;
run feedBES_postscan_episodic.m

%% Loop through pairs
for cPairs=1:length(r.pred.testStim)
    
    % Create textures
    [temp,~,alpha]=imread(['stim/',r.pred.testStim{cPairs,1},'.png']);
    scn_tex=Screen('MakeTexture',w,cat(3,temp,alpha));
    
    % Display
    t1=GetSecs;
    Screen('DrawTexture',w, blank, [],[centerX-250 centerY-300 centerX+250  centerY]);
    Screen('DrawTexture',w, scn_tex, [],[centerX-250 centerY-300 centerX+250 centerY]);
    Screen('DrawTexture', w, obj_tex(1) ,[], [centerX*.25-50 centerY+100 centerX*.25+50 centerY+200]);
    Screen('DrawTexture', w, obj_tex(2) ,[], [centerX*.75-50 centerY+100 centerX*.75+50 centerY+200]);
    Screen('DrawTexture', w, obj_tex(3) ,[], [centerX*1.25-50 centerY+100 centerX*1.25+50 centerY+200]);
    Screen('DrawTexture', w, obj_tex(4) ,[], [centerX*1.75-50 centerY+100 centerX*1.75+50 centerY+200]);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    WaitSecs(.2);
    remainTime=FlipTimestamp-t1;
    [tecla,rt]=collectResp(-1,choiceKeys);
    
    % Code resp
    if strcmpi(KbName(tecla),'1!')
        choice{cPairs}=p.glob.obj_names{1};
    elseif strcmpi(KbName(tecla),'2@')
        choice{cPairs}=p.glob.obj_names{2};
    elseif strcmpi(KbName(tecla),'3#')
        choice{cPairs}=p.glob.obj_names{3};
    elseif strcmpi(KbName(tecla),'4$')
        choice{cPairs}=p.glob.obj_names{4};
    else
        choice{cPairs}='NaN';
    end
    
    % Compute acc and display FB
    if strcmpi(r.pred.testStim{cPairs,2},choice{cPairs})
%         DrawFormattedText(w, 'Well done!','center',centerY-25,white);
%         Screen('Flip', w);
%         WaitSecs(1)
        acc=acc+1;
    else
%         DrawFormattedText(w, 'Wrong answer','center',centerY-25,[200 0 0]);
%         Screen('Flip', w);
%         WaitSecs(1)
    end
    
    % Fix
    Screen('DrawTexture',w, blackTex, [],fixPos);
    Screen('Flip', w);
    WaitSecs(.5);
    
end

% Display performance
DrawFormattedText(w, ['You have finished! Thank you very much.'],...
    'center',centerY-25,white);
Screen('Flip', w);
WaitSecs(3);
r.check=acc;
r.choice_semantic=choice;

% Save run info
save([p.paramName '_postscan_data.mat'],'r')