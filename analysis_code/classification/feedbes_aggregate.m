function feedbes_aggregate(which_sub, glm)
% Aggregate results from feedbes_class.m

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output_dir=[main_folder, '/outputs/group_level/decoding/'];
if ~exist(output_dir)
    mkdir(output_dir)
end

%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    sprintf(['*****************************************\n',...
        'Aggregating %s...'],sub_code)
    
    
    % Load results
    load([sufs.outputs, 'tdt_eye_', glm, '/results.mat'])
    
    % Store
    data{cSub}=output;
    
end

% Now we can aggregate over participants
save([output_dir, glm, '_results.mat'], 'data')