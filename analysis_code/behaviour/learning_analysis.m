%###### Day 1 analysis ######
% #### Day 1 description:
% _Learning phase_: Participants were presented with three learning blocks
% during which the pairs from the episodic set were shown sequentially in a
% computer screen and repeated ten times. Participants were instructed to
% memorize as much detail as possible. At the end of each block,
% knowledge about the scene-object pairings was tested with two tests:
% - Memory for the object identity: four alternatives forced choice test with
%     the scene as cue and the four objects as options
% - Memory for the precise object position: presenting the object misplaced
%     and asking participants to place it back into its original
% position using the arrow keys in the keyboard.
% _Refresh_: Finally, at the end of the session, after one last learning block, the
% two memory tests were repeated.
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
        'Starting day1 analysis of %s.'],sub_code)
    
    try
        % Load params
        load([sufs.day1, '/feedBES_', num2str(cSub), '_params.mat'])
        
        % Load learning phase
        load([sufs.day1, '/feedBES_', num2str(cSub), '_learn_test_Data.mat'])
        day1=r;
        
        % Store this subjects data into a trialXcycleXsubject matrix
        obj_pairing(:,1:5,cSub)=day1.study_object_acc;
        
         % Store this subjects data for position into a trialXcycleXsubject matrix
        obj_pos(:,1:5,cSub)=day1.study_position_acc;
        
        % Load refresh phase
        load([sufs.day1, '/feedBES_', num2str(cSub), '_refresh_test_Data.mat'])
        ref=r;
        
        % Add refresh to Day1 data
        obj_pairing(:,6,cSub)=ref.study_object_acc(:,end);
        obj_pos(:,6,cSub)=ref.study_position_acc(:,end);
        
        % Get demographics
        demo(cSub)=p.demo;
        
    catch
        
        ['Data for ', num2str(cSub), ' is missing']
    end
    
end

%% Let's output this to a csv file to open it in R
out=squeeze(mean(obj_pairing,1))';out=[(1:30)',out];
csvwrite([main_folder, '/outputs/group_level/behaviour/obj_pairing.csv'], out)
out=squeeze(mean(obj_pos,1))';out=[(1:30)',out];
csvwrite([main_folder, '/outputs/group_level/behaviour/obj_pos.csv'], out)