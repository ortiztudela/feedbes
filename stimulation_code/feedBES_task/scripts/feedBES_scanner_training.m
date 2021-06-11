%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Start screen

% Draw fixation
[nx, ny, bbox] = DrawFormattedText (w, '+',centerX,centerY, red); %Get size in pixels of the fixation
DrawFormattedText (w, 'Loading...','center',centerY-100, red);
Screen('Flip', w);

%% Initialize important variables

% Pre-allocate variables for speeding things up
% r.trialOnset=zeros(length(scanner_train_mat),1);r.trialOffset=zeros(length(scanner_train_mat),1);
% r.ITIOnset=zeros(length(scanner_train_mat),1);r.ITIOffset=zeros(length(scanner_train_mat),1);
r.runOnset=[];r.runOffset=[];

%% Run starts here

% Start of run screen
DrawFormattedText(w, 'Are you ready?','center','center',white);
Screen('Flip', w);

%Wait key press
KbWait;

% Store run onset
r.runOnset=GetSecs;

% Select a runMat and remove the semantic trials.
temp=p.pred.runMat(:,:,1);
scanner_train_mat=temp(temp(:,1)==1,:);
tecla=zeros(length(scanner_train_mat)/2,1);

%% Trial loop
for cTrial=1:length(scanner_train_mat)
    
    % Collect onset time
    r.trialOnset(cTrial)=GetSecs-r.runOnset;
    r.current_map(cTrial)=p.pred.runMat(cTrial,3);
    
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
    
    % Draw vividness question
    DrawFormattedText (w, 'How vivid was your memory?','center',centerY-50, white);
    DrawFormattedText (w, p.glob.resp_map{r.current_map(cTrial)},'center',centerY+50, white);
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    elapsedT=FlipTimestamp-r.runOnset-r.ITIOnset(cTrial);
    
    % Record response removing processing delays
    [tecla(cTrial),rt]=collectResp(p.pred.ITIdur-elapsedT,vividKeys);
    if tecla(cTrial) ~=0
        % Draw vividness feedback
        Screen('DrawTexture',w, redTex, [],fixPos);
    end
    [~,~,FlipTimestamp,~,~,] = Screen('Flip', w);
    elapsedT=FlipTimestamp-r.runOnset-r.ITIOnset(cTrial);
    WaitSecs(p.pred.ITIdur-elapsedT); % Leave text on the screen (equate exposure)
    
    % Collect ITIeriod offset time
    r.ITIOffset(cTrial)=GetSecs-r.runOnset;
    
end

% Recode responses
for i=1:length(vividKeys)
    tecla(tecla==vividKeys(i))=i;
end
tecla(r.current_map==2 & tecla' == 1)=4;
tecla(r.current_map==2 & tecla' == 2)=3;
tecla(r.current_map==2 & tecla' == 3)=2;
tecla(r.current_map==2 & tecla' == 4)=1;

% Store data
r.vividness=tecla;

% DieOut period
DrawFormattedText (w, ['You have finished this block. Your average vividness was \n\n ',...
    num2str(mean(r.vividness)), '. Let the experimenter know you have finished.'] ,'center',centerY-100, white);
Screen('Flip', w);

% Save run info
save([p.paramName '_vivid_data.mat'],'r')

%Wait key press
KbWait;
