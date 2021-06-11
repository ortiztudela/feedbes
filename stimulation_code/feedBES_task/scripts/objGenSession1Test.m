%% Project: MEMORY-DRIVEN PREDICTIONS. Object generation task. Memory test.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
Screen('DrawTexture',w, blackTex, [],fixPos);
Screen('Flip', w);
WaitSecs(p.fixTime);

%% Run starts here
% Initialize variables for storage
Screen('TextSize', w, 50);                       % Text size

% Start of run screen
DrawFormattedText(w, 'Are you ready? Press any key to start',...
    'center','center',white);
WaitSecs(.2)
Screen('Flip', w);
KbWait;

% Initiate
KbName('UnifyKeyNames')
choiceKeys=[KbName('rightarrow');KbName('leftarrow')];
acc=0;

% Randomize
randOrd=randperm(8);

for cPairs=1:p.nPairs
    
    %Scene
    cueTex=Screen('MakeTexture',w,p.epiIm(:,:,:,randOrd(cPairs)));
    objText1=Screen('MakeTexture',w,p.semObj(:,:,:,1));%objTex(1);objText2=objTex(5);
    objText2=Screen('MakeTexture',w,p.semObj(:,:,:,5));
    currCol=p.fixCol{randOrd(cPairs)};
    
    % Display
    t1=GetSecs;
    Screen('DrawTexture',w, blank, [],[centerX-250 centerY-300 centerX+250  centerY]);
    Screen('DrawTexture',w, cueTex, [],[centerX-250 centerY-300 centerX+250 centerY]);
    Screen('DrawTexture', w, objText1 ,[], [centerX-500 centerY+100 centerX-100 centerY+300]);
    Screen('DrawTexture', w, objText2 ,[], [centerX+100 centerY+100 centerX+500 centerY+300]);
    if strcmpi(currCol,'blue')
        Screen('DrawTexture',w, blueTex, [],[centerX-10 centerY-160 centerX+10 centerY-140]);
    elseif strcmpi(currCol,'green')
        Screen('DrawTexture',w, greenTex, [],[centerX-10 centerY-160 centerX+10 centerY-140]);
    end
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    WaitSecs(.2)
    remainTime=FlipTimestamp-t1;
    [tecla,rt]=collectResp(-1,choiceKeys);
    
    % Code resp
    if tecla == KbName('leftarrow')
        choice='oven';
    elseif tecla == KbName('rightarrow')
        choice = 'umbr';
    end
    
    % Compute acc and display FB
    if min(choice==p.stimMat{2,randOrd(cPairs)})
        DrawFormattedText(w, 'Well done!','center',centerY-25,white);
        Screen('Flip', w);
        WaitSecs(1)
        acc=acc+1;
    else
        DrawFormattedText(w, 'Wrong answer','center',centerY-25,[200 0 0]);
        Screen('Flip', w);
        WaitSecs(1)
    end
    
    % Fix
    Screen('DrawTexture',w, blackTex, [],fixPos);
    Screen('Flip', w);
    WaitSecs(.5)
    
end

% Display performance
DrawFormattedText(w, ['You remembered ' num2str(acc) ' out of 8 combinations'],...
    'center',centerY-25,white);
Screen('Flip', w);
WaitSecs(3)
KbWait
r.session1acc=acc;

% Save run info
save([p.paramName '_preScanMemData.mat'],'r')