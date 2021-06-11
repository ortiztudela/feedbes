%% Project: MEMORY-DRIVEN mapICTIONS. Object generation task.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
[nx, ny, bbox] = DrawFormattedText (w, '+',centerX,centerY, red); %Get size in pixels of the fixation
DrawFormattedText (w, 'Loading...','center',centerY-100, red);
Screen('Flip', w);

%% InIBIalize important variables

% Pre-allocate variables for speeding things up
r.trialOnset=zeros(p.map.nBlocks,1);r.trialOffset=zeros(p.map.nBlocks,1);
r.IBIOnset=zeros(p.map.nBlocks,1);r.IBIOffset=zeros(p.map.nBlocks,1);
r.runOnset=[];r.runOffset=[];
cross_color=redTex;

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
remainingT=p.map.riseT-(FlipTimestamp-r.firstPulse);
collectResp(remainingT,escCode);

% Store run onset
r.runOnset=GetSecs;

% Collect a few volumes after the dummy
Screen('DrawTexture',w, blackTex, [],fixPos);
[~,~,FlipTimestamp,~,~,]=Screen('Flip', w);
remainingT=2-(FlipTimestamp-r.runOnset);
collectResp(remainingT,escCode);

%% Trial loop
for cBlock=1:length(p.map.expDes)
    
    % Collect onset time
    r.trialOnset(cBlock)=GetSecs-r.runOnset;
    
    % Select scene for this trial
    if p.map.expDes(cBlock,1)==10 % If peri targ
        sel_tex(cBlock)=peri;
        sel_tex_inv(cBlock)=peri_inv;
        r.map.block_label{cBlock}='peri';
    elseif p.map.expDes(cBlock,1)==11 % If peri surr
        sel_tex(cBlock)=peri_surr;
        sel_tex_inv(cBlock)=peri_surr_inv;
        r.map.block_label{cBlock}='peri_surr';
    elseif p.map.expDes(cBlock,1)==12 % If fov surr
        sel_tex(cBlock)=fov;
        sel_tex_inv(cBlock)=fov_inv;
        r.map.block_label{cBlock}='fov';
    elseif p.map.expDes(cBlock,1)==13 % If fov surr
        sel_tex(cBlock)=fov_surr;
        sel_tex_inv(cBlock)=fov_surr_inv;
        r.map.block_label{cBlock}='fov_surr';
    end
    
    %% Display stimulation at flasFreq Hz
    for i=1:p.map.blockDur*p.map.flashFreq
        t1=GetSecs;
        % Check for ESCAPE
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        if keyCode(escCode)==1
            Screen('CloseAll');
            error('Aborted by user')
        end
        
        % Randomly select when to flash a green fixation cross
        cross_change=randi(10);
        if cross_change==10
            cross_color=greenTex;
        end
        if keyCode(respKeys(1))==1 || keyCode(respKeys(2))==1 || ...
                keyCode(respKeys(3))==1 || keyCode(respKeys(4))==1
            cross_color=redTex;
        end
        
        % ChB
        Screen('DrawTexture',w, sel_tex(cBlock), [],scenePos);
        Screen('DrawTexture',w, cross_color, [],fixPos);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        elapsedT=FlipTimestamp-t1;
        WaitSecs((p.map.duration/2)-elapsedT); %Remove stupid delay
                
        % ChB inverted
        t1=GetSecs;
        Screen('DrawTexture',w, sel_tex_inv(cBlock), [],scenePos);
        Screen('DrawTexture',w, cross_color, [],fixPos);
        [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
        elapsedT=FlipTimestamp-t1;
        WaitSecs((p.map.duration/2)-elapsedT); %Remove stupid delay
    end
    
    % Collect trial offset time
    r.trialOffset(cBlock)=GetSecs-r.runOnset;
    
    %% Start IBI period (IBI)
    % Collect IBI period onset time
    r.IBIOnset(cBlock)=GetSecs-r.runOnset;
    
    % Encouraging message
    if cBlock==12
        DrawFormattedText(w, 'The first half is already completed. You are doing great!','center','center',white);
        Screen('Flip', w);        
        WaitSecs(4);
    end
    % Draw fixation
    Screen('DrawTexture',w, redTex, [],fixPos);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    
    % Wait a few milliseconds to account for processing delays
    elapsedT=FlipTimestamp-r.runOnset-r.IBIOnset(cBlock);
    collectResp(p.map.IBIdur-elapsedT,escCode);
    
    % Collect IBIeriod offset time
    r.IBIOffset(cBlock)=GetSecs-r.runOnset;
    
end

% DieOut period
DrawFormattedText (w, ['This run has finished. You can close your eyes; \n\n '...
    'we will be done in a few seconds. Remember to try not to move.'] ,'center',centerY-100, white);
Screen('Flip', w);
WaitSecs(p.map.dieOutT);

% Collect onset time
r.runOffset=GetSecs-r.runOnset;

% Save run info
save([p.paramName '_mapping_data.mat'],'r')
% saveData(p.map.taskName,p.subjectcode,cRun,'prt')
