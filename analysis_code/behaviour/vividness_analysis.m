%###### Day 1 analysis ######
% #### Day 1 description:
% _Scanner practice_: After the learning phase, participants performed one 
% block of the object retrieval task to familiarize themselves the task. 
% A trial-by-trial vividness rating was performed. On every trial, participants 
% were asked to report their subjective vividness of the retrieved object 
% on a four points scale.

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
        load([sufs.day1, '/feedBES_', num2str(cSub), '_vivid_data.mat'])
        day1=r;
        
        % Store this subjects data into a trialXcycleXsubject matrix
        vivid(cSub)=mean(day1.vividness);
       
    catch
        
        ['Data for ', num2str(cSub), ' is missing']
    end
    
end

%% Let's output this to a csv file to open it in R
out=[(1:30)',vivid'];
csvwrite([main_folder, '/outputs/group_level/behaviour/vivid_task.csv'], out)