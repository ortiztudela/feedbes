%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------

%% Load image files to store them in .mat files.
%%%%% First we define the stimulus names, load them and store them 
%%%%% into a glob variable.

% Define stimuli names
glob.scn_names={'livingroom','bathroom','kitchenstore','bedstore',...
    'livingroom2','bathroom2','kitchenstore2','bedstore2',...
    'electronics','bathstore','kitchen','bedroom',...
    'electronics2','bathstore2','kitchen2','bedroom2'};
glob.obj_names={'tv','bathtub','oven','bed'};
glob.obj_displX=[1,-1,0,0]; % Positive and negative displacement X axis
glob.obj_displY=[0,0,1,-1]; % Positive and negative displacement Y axis

%% Stimulus counterbalancing
%%%%% Re-arrange the glob variable according to the CB

% Select set of scenes based on subject numbe There are two levels because
% we have two memory conditions
if mod(p.subjectcode,2)==1
    glob.scn_names=[glob.scn_names(1:8),glob.scn_names(9:16)];
    glob.obj_displX=[glob.obj_displX(1:2),glob.obj_displX(3:4)];
    glob.obj_displY=[glob.obj_displY(1:2),glob.obj_displY(3:4)];
elseif mod(p.subjectcode,2)==0
    glob.scn_names=[glob.scn_names(9:16),glob.scn_names(1:8)];
    glob.obj_displX=[glob.obj_displX(3:4),glob.obj_displX(1:2)];
    glob.obj_displY=[glob.obj_displY(3:4),glob.obj_displY(1:2)];
end
glob.obj_displX=[repmat(glob.obj_displX',2,1);...
    glob.obj_displX(end)';glob.obj_displX(1:end-1)';...
    glob.obj_displX(end)';glob.obj_displX(1:end-1)'];
glob.obj_displY=[repmat(glob.obj_displY',2,1);...
    glob.obj_displY(end)';glob.obj_displY(1:end-1)';...
    glob.obj_displY(end)';glob.obj_displY(1:end-1)'];

% Select CB level for objects. There are three levels because we have 4 objects 
% and one of them cannot be paired with its semantically associated scene
glob.cb_lvl=mod(p.subjectcode,3)+2;
glob.obj_names=[
    glob.obj_names(glob.cb_lvl:end),glob.obj_names(1:glob.cb_lvl-1),...
    glob.obj_names(glob.cb_lvl:end),glob.obj_names(1:glob.cb_lvl-1),...
    glob.obj_names,glob.obj_names];


% Put scns and objects into one matrix for easier future use
glob.stimMat=[glob.scn_names',glob.obj_names',num2cell(glob.obj_displX),...
    num2cell(glob.obj_displY)];

%% Load images

% Load every scene
temp=[];
for i=1:length(glob.scn_names)
    [temp,~,alpha]=imread(['stim/',glob.scn_names{i},'.png']);
    temp(:,:,4)=alpha;
    glob.scn(:,:,:,i)=temp;
end

% Load every object
temp=[];
for i=1:length(glob.obj_names)
    [temp,~,alpha]=imread(['stim/',glob.obj_names{i},'.png']);
    temp(:,:,4)=alpha;
    glob.obj(:,:,:,i)=temp;
end

% Plot for visual inspection
if pS
    figure(1)
    for i=1:length(glob.scn_names)/2
        subplot(3,4,i), imagesc(squeeze(glob.scn(:,:,1:3,i)))
        axis('off'); title(glob.scn_names{i})
    end

    for i=1:length(glob.obj_names)/4
        subplot(3,4,i+8), imagesc(squeeze(glob.obj(:,:,1:3,i)))
        axis('off');title(glob.obj_names{i})
    end
    sgtitle('episodic pairs')
    figure(2)
    for i=9:length(glob.scn_names)
        subplot(3,4,i-8), imagesc(squeeze(glob.scn(:,:,1:3,i)))
        axis('off'); title(glob.scn_names{i})
    end
    for i=9:12
        subplot(3,4,i), imagesc(squeeze(glob.obj(:,:,1:3,i)))
        axis('off')
    end
    sgtitle('semantic pairs')
end

%% Stimulus arrangement
%%%%% Now that the images have been loaded, we will create the trial-wise
%%%%% labels according to the expDes of each phase. The labels will be 
%%%%% stored in the respective variables. These won't be used in
%%%%% the rest of the script other than for creating output files. No
%%%%% randomization or re-arrangement of the glob variable can be done from
%%%%% here on. 

%%% Learning phase %%%
% ----------------------------------------------------------

% Nothing special to do here because reasons (see DesAndVam).


%%% Prediction phase %%%
% ----------------------------------------------------------

% Select the labels in the appropriate order
for cRun=1:pred.nRuns
    for cTrial=1:pred.nTrials
        if pred.runMat(cTrial,1,cRun)==1 % If episodic
            pred.scn_labels(cTrial,cRun)=glob.stimMat(0+pred.runMat(cTrial,2,cRun),1);
            pred.obj_labels(cTrial,cRun)=glob.stimMat(0+pred.runMat(cTrial,2,cRun),2);
            pred.disp_labelsX(cTrial,cRun)=glob.stimMat{0+pred.runMat(cTrial,2,cRun),3};
            pred.disp_labelsY(cTrial,cRun)=glob.stimMat{0+pred.runMat(cTrial,2,cRun),4};
        elseif pred.runMat(cTrial,1,cRun)==2 % If semantic
            pred.scn_labels(cTrial,cRun)=glob.stimMat(8+pred.runMat(cTrial,2,cRun),1);
            pred.obj_labels(cTrial,cRun)=glob.stimMat(8+pred.runMat(cTrial,2,cRun),2);
        end
    end
end

%%% Sensory template %%%
% ----------------------------------------------------------

% Select the labels in the appropriate order

for cTrial=1:sens.nTrials
    sens.stim_labels{cTrial}=glob.stimMat{sens.expDes(cTrial),1};
    sens.obj_labels{cTrial}=glob.stimMat{sens.expDes(cTrial),2};
    sens.disp_labelsX{cTrial}=glob.stimMat{sens.expDes(cTrial),3};
    sens.disp_labelsY{cTrial}=glob.stimMat{sens.expDes(cTrial),4};
end

%%% Target mapping phase %%%
% ----------------------------------------------------------

% We just need to define the stimuli names here since the rest is done
% either in the createTextures.m or the main task script.

% Define stimuli names 
chBLabels={'Periph_Target';'Periph_Surrounding';'Phovea_Target';'Phovea_Surrounding'};


%% Set fixation crosses
% Load black fixation
[glob.black_fix,~,alpha]=imread('stim/fixation.png');

% Get indeces for black pixels
temp=find(glob.black_fix(:,:,1)==0);

% Separate the three chanels
fix_R=glob.black_fix(:,:,1);fix_G=glob.black_fix(:,:,2);fix_B=glob.black_fix(:,:,3);
glob.black_fix=cat(3,glob.black_fix,alpha);

% Get red fixation
fix_R(temp)=200;fix_G(temp)=0;fix_B(temp)=200;
glob.red_fix=cat(3,fix_R,fix_G,fix_B,alpha);

% Get red fixation
fix_R(temp)=0;fix_G(temp)=200;fix_B(temp)=200;
glob.green_fix=cat(3,fix_R,fix_G,fix_B,alpha);


%% Response mappings for vividness question
glob.resp_map{1}='| 1 ----- 2 ----- 3 ----- 4 |';
glob.resp_map{2}='| 4 ----- 3 ----- 2 ----- 1 |'; % This is included in case 
% we want to use it in the future for the scanner task. If that is the
% case, then the second cell of the resp_map variable can be called.

