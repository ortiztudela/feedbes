%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% Design set up and definition of important variables
% ----------------------------------------------------------

%% Define important variables
%%% Learning phase %%%
% ----------------------------------------------------------

learn.nPairs = 8;                             % number of different pairs per condition
learn.nConditions = 1;
% learn.nRepetitions= 10;                        % number of repetitions of each pair per
learn.nTrials = learn.nPairs * learn.nConditions;        % number of different parings
learn.trialDur = 10;
learn.displ = .25;                  % object displacement in relation to object size
learn.nCycles = 5;                  % number of study cycles
learn.ITIdur = .5;
learn.fixTime = .5;                            % fixation duration (secs)
learn.testDur = 2;                  % trial duration for the test phase
learn.check_dur = 5;           % duration of the object checking trials
learn.nCheckTrials = 8;         % number of object checking trials
learn.posDispl=[1,0;-1,0;0,1;0,-1];         % possible displacements
    
%%% Prediction phase %%%
% ----------------------------------------------------------

pred.TR = .8;
pred.riseT= 6 * pred.TR;                               % blank period at the beggining
pred.dieOutT=pred.riseT;                             % blank period at the end
pred.nPairs = 8;                  % number of different pairs per condition
pred.nConditions = 2;
pred.nRepetitions= 6;                       % number of repetitions of each pair per run
pred.nTrials = pred.nPairs * pred.nRepetitions * pred.nConditions;        % number of trials
pred.trialDur= 6;
pred.stimDur = 4;                            % scene duration (secs)
pred.flashFreq = 5;                          % flashing frequency (Hz)
pred.duration = 1/pred.flashFreq;            % duration of each presentation
pred.ITIdur = pred.trialDur-pred.stimDur;
pred.nRuns = 4;                              % number of runs
pred.nVols = ceil((pred.riseT +2+ (pred.nTrials*pred.trialDur) + ...
    +  pred.dieOutT )/pred.TR);

%%% Target mapping phase %%%
% ----------------------------------------------------------

map.TR = .8;
map.riseT= 6 * map.TR;                              % blank period at the beggining
map.dieOutT=map.riseT;                              % blank period at the end
map.nChB=4;                                 % Number of locations to map
map.nRepetitions = 6;
map.nBlocks=map.nChB*map.nRepetitions;
map.blockDur = 12;                          % scene duration (secs)
map.flashFreq = 2;                          % flashing frequency (Hz)
map.duration = 1/map.flashFreq;               % duration of each presentation
map.IBIdur = 12;
map.nVols = ceil((map.riseT +2+ (map.nBlocks*(map.blockDur+map.IBIdur)) ...
    +  map.dieOutT )/map.TR); % 2 seconds are added to allow a few volumes after removing the dummy

%%% Sensory template %%%
% ----------------------------------------------------------

sens.TR = .8;
sens.riseT=6 * sens.TR;                              % blank period at the beggining
sens.dieOutT=sens.riseT;                             % blank period at the end
sens.nObjects = 0;                             % number of objects
sens.nScnes = 16;
sens.nRepetitions= 12;                        % number of repetitions of each pair per run
sens.nTrials = (sens.nObjects + sens.nScnes) * sens.nRepetitions;        % number of different parings
sens.trialDur = 1.5;
sens.ITIdur = 1;
sens.fixTime = 1;                            % fixation duration (secs)
sens.nVols = ceil((sens.riseT +2+ (sens.nTrials*(sens.trialDur+sens.ITIdur)) ...
    +  sens.dieOutT)/sens.TR); % 2 seconds are added to allow a few volumes after removing the dummy


%% Experimental design.
%%% Learning phase %%%
% ----------------------------------------------------------

% Exp structure.
% I'm not creating an expDes matrix here because I can't think of a reason
% why we would want it in the future. In the main script however, the order
% of the stimulus presentation is being stored, so it would possible to
% reconstruct the matrix if needed at some point.

%%% Prediction phase %%%
% ----------------------------------------------------------

% Exp structure. Trials X Variables X Runs
% Columns are: Trial type (Epi-Sem), Scene categ (8 cats)
pred.expDes(:,1)=sort(repmat([1,2],1,pred.nTrials/2))'; % Trial type
pred.expDes(:,2)=repmat(1:8,1,pred.nRepetitions*pred.nConditions)';
pred.expDes(:,3)=repmat(sort(repmat([1,1],1,pred.nTrials/4)),1,2)'; % Key mapping
% This is included in case we want to use it in the future for the scanner task. 

% Shuffle trial order for each run
for cRun=1:pred.nRuns
    pred.runMat(:,:,cRun)=pred.expDes(randperm(pred.nTrials),:);
end

if pD
    
    subplot(2,4,2:3),imagesc(pred.expDes(:,1:end))
    xticks([1:3]);xticklabels({'Trial type';'Scene categ'; 'key mapping'})
    xtickangle(45);title('Exp Design')
    ylabel('Trials')
    for cRun=1:pred.nRuns
        subplot(2,4,4+cRun),imagesc(pred.runMat(:,:,cRun))
        xticks([1:3]);xticklabels({'Trial type';'Scene categ'; 'key mapping'})
        xtickangle(45);title(['run ',num2str(cRun)])
    end
    
end

%%% Target mapping phase %%%
% ----------------------------------------------------------

% Exp structure. Block type (Periph-Target,Periph-Surr, Fov-Target, Fov-Surr)
map.expDes=repmat((10:13),1,map.nRepetitions)';

% Shuffle trial order
map.expDes=map.expDes(randperm(map.nBlocks),:);

%%% Sensory template %%%
% ----------------------------------------------------------

% Load designs from OptimizeXGUI. These need to be generated before and
% place into the scripts folder.
load designinfo.mat

% Select the appropriate one based on the subjectcode
CB_sens=mod(p.subjectcode,20)+1;
sens.sel_des=design{CB_sens};
sens.expDes=sens.sel_des.combined(:,2);

% Plot for visual inspection
if pD
    
    figure
    subplot(1,2,1),imagesc(sort(sens.expDes))
    xticks([1]);xticklabels({'Stimuli'})
    xtickangle(45);title('Exp Design')
    ylabel('Trials')
    
    subplot(1,2,2),imagesc(sens.expDes)
    xticks([1]);xticklabels({'Stimuli'})
    xtickangle(45);title('Shuffled design')
    ylabel('Trials')
    
end
