%% FeedBES HC mask corregistration
% This script is merely a wrapper to loop over participants to register the
% HC mask from ASHS

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output=[];here=cd;

which_sub=[1:5,7:30];
%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    %% Register
   feedbes_ashs_subfields_correg(cSub, sufs, sub_code)
    
end