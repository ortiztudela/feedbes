%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Create textures
% This scripts creates the texture needed for each session. It is done
% here and not in the main script to keep it cleanear and it is done prior
% to the start of the task to avoid comptuing delays in
% creating textures.

%% Create main textures

if session == 1 || session == 7 || session == 6 % Learning phase
    
    %%% Create scenes and objects textures %%%
    % ----------------------------------------------------------
    
    % Scenes
    for i=1:p.learn.nTrials
        scnTex(i)=Screen('MakeTexture',w,p.glob.scn(:,:,:,i));
    end
    
    % Objects
    for i=1:p.learn.nTrials
        objTex(i)=Screen('MakeTexture',w,p.glob.obj(:,:,:,i));
    end
    
    % Load arrows for the check
    [temp,~,alpha]=imread('stim/arrows.png');temp(:,:,4)=alpha;
    arrow_tex=Screen('MakeTexture',w,temp);
    
elseif session == 2 % Scanner training task
    
    %%% Create scenes textures %%%
    % ----------------------------------------------------------
    
    % Scenes
    for i=1:p.pred.nPairs*2
        scnTex(i)=Screen('MakeTexture',w,p.glob.scn(:,:,:,i));
    end
    
    % Objects
    for i=1:p.learn.nPairs*2
        objTex(i)=Screen('MakeTexture',w,p.glob.obj(:,:,:,i));
    end
    
    % Select the textures in the appropriate order
    counter=1;
    for cTrial=1:p.pred.nTrials
        if p.pred.runMat(cTrial,1,1)==1 % If episodic
            sel_tex(counter)=scnTex(0+p.pred.runMat(cTrial,2,1));
            sel_obj_tex(counter)=objTex(0+p.pred.runMat(cTrial,2,1));
            counter=counter+1;
        end
    end
    
    % Load arrows for the check
    [temp,~,alpha]=imread('stim/arrows.png');temp(:,:,4)=alpha;
    arrow_tex=Screen('MakeTexture',w,temp);
    
    elseif session == 3 % Scanner task
    
    %%% Create scenes textures %%%
    % ----------------------------------------------------------
    
    % Scenes
    for i=1:p.pred.nPairs*2
        scnTex(i)=Screen('MakeTexture',w,p.glob.scn(:,:,:,i));
    end
    
    % Objects
    for i=1:p.learn.nPairs*2
        objTex(i)=Screen('MakeTexture',w,p.glob.obj(:,:,:,i));
    end
    
    % Select the textures in the appropriate order
    curr_run=cRun;
    for cTrial=1:p.pred.nTrials
        if p.pred.runMat(cTrial,1,curr_run)==1 % If episodic
            sel_tex(cTrial)=scnTex(0+p.pred.runMat(cTrial,2,curr_run));
            sel_obj_tex(cTrial)=objTex(0+p.pred.runMat(cTrial,2,curr_run));
        elseif p.pred.runMat(cTrial,1,curr_run)==2 % If semantic
            sel_tex(cTrial)=scnTex(8+p.pred.runMat(cTrial,2,curr_run));
            sel_obj_tex(cTrial)=objTex(8+p.pred.runMat(cTrial,2,curr_run));
        end
    end
    
    
    % Load arrows for the check
    [temp,~,alpha]=imread('stim/arrows.png');temp(:,:,4)=alpha;
    arrow_tex=Screen('MakeTexture',w,temp);
    
elseif session == 4
    
    %%% Create chB textures %%%
    % ----------------------------------------------------------
    
    peri=Screen('MakeTexture',w,imread('stim/peri_targ.png'));
    peri_inv=Screen('MakeTexture',w,imread('stim/peri_targ_inv.png'));
    peri_surr=Screen('MakeTexture',w,imread('stim/peri_surr.png'));
    peri_surr_inv=Screen('MakeTexture',w,imread('stim/peri_surr_inv.png'));
    fov=Screen('MakeTexture',w,imread('stim/phov_targ.png'));
    fov_inv=Screen('MakeTexture',w,imread('stim/phov_targ_inv.png'));
    fov_surr=Screen('MakeTexture',w,imread('stim/phov_surr.png'));
    fov_surr_inv=Screen('MakeTexture',w,imread('stim/phov_surr_inv.png'));
    
elseif session == 5
    
    %%% Create sensory template textures %%%
    % ----------------------------------------------------------
    
    % Scenes
    for i=1:p.sens.nScnes
        scnTex(i)=Screen('MakeTexture',w,p.glob.scn(:,:,:,i));
    end
    
    % Objects
    for i=1:p.sens.nScnes
        objTex(i)=Screen('MakeTexture',w,p.glob.obj(:,:,:,i));
    end
    
    % Select the textures in the appropriate order
    for cTrial=1:p.sens.nTrials
        % Get current trial stim
        stimTex(cTrial)=scnTex(p.sens.expDes(cTrial));
        objTexture(cTrial)=objTex(p.sens.expDes(cTrial));
    end
end

%% Create some more textures

% Black fixation
blackTex=Screen('MakeTexture',w,p.glob.black_fix);

% Red fixation
redTex=Screen('MakeTexture',w,p.glob.red_fix);
greenTex=Screen('MakeTexture',w,p.glob.green_fix);

if session ~= 4 % Create these textures for all other than the target mapping block
    % Create background texture
    [temp,~,alpha]=imread('stim/background.png');
    blank=Screen('MakeTexture',w,temp);
    
    if session == 1 || session == 2 || session == 3 || session == 7 || session == 6
        
        % Create occluder texture
        [temp,~,alpha]=imread('stim/occluder.png');
        temp(:,:,4)=alpha;
        patch=Screen('MakeTexture',w,temp);%cat(3,temp,alpha));
    end
end