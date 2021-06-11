%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
Screen('DrawTexture',w, blackTex, [],fixPos);
Screen('Flip', w);
WaitSecs(p.learn.fixTime);

%% Run starts here
% Initialize variables for storage
r.learn.testStim=p.glob.stimMat(randperm(p.learn.nTrials),:);
c=1;
Screen('TextSize', w, 30);                       % Text size

% Start of run screen
DrawFormattedText(w, ['Are you ready for a quick test? \n\n You will need to',...
    ' select which object is hidden under the white patch and \n\n',...
    ' to place it in its original position.  \n\n',...
    ' Press 1 to start'],...
    'center','center',white);
WaitSecs(.2)
Screen('Flip', w);
% KbWait;
collectResp(-1,choiceKeys);

% Create object textures
for cObj=1:4
    [temp,~,alpha]=imread(['stim/',p.glob.stimMat{cObj,2},'.png']);
    obj_tex(cObj)=Screen('MakeTexture',w,cat(3,temp,alpha));
end

%% Loop through pairs
check_response=zeros(length(r.learn.testStim),2,2);
if cCycle==1
    obj_acc=zeros(p.learn.nTrials*2,1);
    pos_acc=zeros(p.learn.nTrials*2,1);
end
for cRep=1
    
    % Create a random sequence for this repetition loop
    r.randOrd_check(:, cRep)=randperm(8);
    for cPairs=1:p.learn.nTrials
        
        % Pre-allocate
        r.choice_num(cPairs)=0;
        
        % Create textures
        [temp,~,alpha]=imread(['stim/',p.glob.stimMat{r.randOrd_check(cPairs,cRep),1},'.png']);
        scn_tex=Screen('MakeTexture',w,cat(3,temp,alpha));
        
        % Display
        t1=GetSecs;
        Screen('DrawTexture',w, blank, [],[centerX-500 centerY-400 centerX+500 centerY+200]);
        Screen('DrawTexture',w, scn_tex, [],[centerX-500 centerY-400 centerX+500 centerY+200]);
        Screen('DrawTexture',w, patch, [],[centerX-500 centerY-400 centerX+500 centerY+200]);
        Screen('DrawTexture', w, obj_tex(1) ,[], [centerX*.5-50 centerY+250 centerX*.5+50 centerY+350]);
        DrawFormattedText(w, '1',centerX*.5,centerY+500,white);
        Screen('DrawTexture', w, obj_tex(2) ,[], [centerX*.85-50 centerY+250 centerX*.85+50 centerY+350]);
        DrawFormattedText(w, '2',centerX*.85,centerY+500,white);
        Screen('DrawTexture', w, obj_tex(3) ,[], [centerX*1.15-50 centerY+250 centerX*1.15+50 centerY+350]);
        DrawFormattedText(w, '3',centerX*1.15,centerY+500,white);
        Screen('DrawTexture', w, obj_tex(4) ,[], [centerX*1.5-50 centerY+250 centerX*1.5+50 centerY+350]);
        DrawFormattedText(w, '4',centerX*1.5,centerY+500,white);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        WaitSecs(.2);
        remainTime=FlipTimestamp-t1;
        [tecla,~]=collectResp(p.learn.testDur+5,choiceKeys);
        
        % Code resp
        if tecla ~= 0
            r.choice_num(cPairs) = find(choiceKeys==tecla);
            r.choice{cPairs}=p.glob.stimMat{r.choice_num(cPairs),2};
        else
            r.choice{cPairs}=NaN;
        end
        
        % Compute acc and display FB
        if strcmpi(p.glob.stimMat{r.randOrd_check(cPairs,cRep),2},r.choice{cPairs})
%             DrawFormattedText(w, 'Well done!',center',centerY-25,white);
            obj_acc(c)=1;
        elseif r.choice_num(cPairs)==0
            DrawFormattedText(w, 'Too slow!','center',centerY-25,[200 0 0]);
             obj_acc(c)=0;
        else
%             DrawFormattedText(w, 'Wrong answer','center',centerY-25,[200 0 0]);
             obj_acc(c)=0;
        end
        Screen('Flip', w);
        WaitSecs(.5);
        
        % Stim labels
        r.learn.scn_namesCheck{cPairs,cRep,cCycle}=p.glob.scn_names{r.randOrd_check(cPairs,cRep)};
        r.learn.obj_namesCheck{cPairs,cRep,cCycle}=p.glob.obj_names{r.randOrd_check(cPairs,cRep)};
        r.learn.displXCheck(cPairs,cRep,cCycle)=p.glob.stimMat(r.randOrd_check(cPairs,cRep),3);
        r.learn.displYCheck(cPairs,cRep,cCycle)=p.glob.stimMat(r.randOrd_check(cPairs,cRep),4);
        
        % Assess standard displacement
        trial_displ=[displ(1)*p.glob.stimMat{r.randOrd_check(cPairs,cRep),3},displ(2)*p.glob.stimMat{r.randOrd_check(cPairs,cRep),4}...
            displ(1)*p.glob.stimMat{r.randOrd_check(cPairs,cRep),3},displ(2)*p.glob.stimMat{r.randOrd_check(cPairs,cRep),4}];
        objRect_trial=objRect+trial_displ;
        
        % Assess additional displacement
        check_displ=p.learn.posDispl(randi(4),:);
        add_displ=[displ(1)*check_displ(1),displ(2)*check_displ(2)...
            displ(1)*check_displ(1),displ(2)*check_displ(2)];
        
        % Display
        t1=GetSecs;
        Screen('DrawTexture',w, blank, [], scenePos);
        Screen('DrawTexture',w, scn_tex, [], scenePos);
        Screen('DrawTexture', w, objTex(r.randOrd_check(cPairs,cRep)) ,[], objRect_trial+add_displ);
        Screen('DrawTexture',w, arrow_tex, [],[centerX-100 centerY-100 centerX+100 centerY+100]);
        DrawFormattedText(w, 'Move the object to its original position','center',scenePos(2)-50,white);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        WaitSecs(.2);
        elpasedT=FlipTimestamp-t1;
        [tecla,rt]=collectResp(p.learn.check_dur+5-elpasedT,checkKeys);
        
        % Code response
        if tecla==checkKeys(1)
            check_response(cPairs,:,cRep)=[1,0];
        elseif tecla==checkKeys(2)
            check_response(cPairs,:,cRep)=[0,1];
        elseif tecla==checkKeys(3)
            check_response(cPairs,:,cRep)=[-1,0];
        elseif tecla==checkKeys(4)
            check_response(cPairs,:,cRep)=[0,-1];
        else
            check_response(cPairs,:,cRep)=[0,0];
        end
        
        % Compute acc and display FB
        t1=GetSecs;
        Screen('DrawTexture',w, blank, [], scenePos);
        Screen('DrawTexture',w, scn_tex, [], scenePos);
        Screen('DrawTexture', w, objTex(r.randOrd_check(cPairs,cRep)) ,[], objRect_trial);
        
        if mean(check_response(cPairs,:,cRep)==check_displ)==1
%             DrawFormattedText(w, 'Well done!','center',centerY-25,white);
            pos_acc(c)=1;
        else
%             DrawFormattedText(w, 'Wrong answer','center',centerY-25,[200 0 0]);
            pos_acc(c)=0;
        end
        Screen('Flip', w);
        WaitSecs(.5);
        
        % Fix
        Screen('DrawTexture',w, blackTex, [],fixPos);
        Screen('Flip', w);
        WaitSecs(.5);
        c=c+1;
        
    end

end

r.study_object_acc(:,cCycle)=obj_acc;
r.study_position_acc(:,cCycle)=pos_acc;
r.study_position_resp{cCycle}=check_response;

% Save run info
if cCycle < 6    
    save([p.paramName '_learn_test_Data.mat'],'r')
elseif cCycle == 6
    save([p.paramName '_refresh_test_Data.mat'],'r')
end