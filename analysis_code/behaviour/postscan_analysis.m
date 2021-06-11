%###### Day 2 analysis ######
% #### Day 2 description:
% _Post-scan phase_: Participants performed a memory test (identical to
% that in the learning phase) that checked for scene-object associations
% (both for episodic and semantic pairings). In addition, in the case of
%     the episodic trials, we checked for correct positioning of the objects
%     in the scene.
% Three subjects (the first three, i.e., 7,8,13) had a shorter version for
% which there's no data available.
clear
close all

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])

which_sub=[1:5,7:30];
%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    sprintf(['*****************************************\n',...
        'Starting postscan analysis of %s.'],sub_code)
    
    try
        % Load params
        load([sufs.post, '/feedBES_', num2str(cSub), '_params.mat'])
        
        % Load learning phase
        load([sufs.post, '/feedBES_', num2str(cSub), '_postscan_data.mat'])
        post=r;
        
        % Store this subjects data into a trialXcycleXsubject matrix
        obj_pairing(:,cSub)=post.study_object_acc(:,end);
        
        % Store this subjects data for position into a trialXcycleXsubject matrix
        obj_pos(:,cSub)=post.study_position_acc(:,end);
        
        % Look at semantic pairings
        for cPairs=1:length(post.pred.testStim)
            if strcmpi(post.pred.testStim{cPairs,2},post.choice_semantic{cPairs})
                sem_pairing(cPairs,cSub)=1;
            end
        end
        
    catch
        
        ['Data for ', num2str(cSub), ' is missing']
    end
    
end
% Concatenate epi and sem
pairing=[ones(30,1);ones(30,1)*2];
pairing=[pairing,[squeeze(mean(obj_pairing,1))';squeeze(mean(sem_pairing))']];
%% Let's output this to a csv file to open it in R
out=[[(1:30)';(1:30)'],pairing];
csvwrite([main_folder, '/outputs/group_level/behaviour/postscan_pairing.csv'], out)
out=squeeze(mean(obj_pos,1))';out=[(1:30)',out];
csvwrite([main_folder, '/outputs/group_level/behaviour/postscan_pos.csv'], out)