%% FeedBES HC mask corregistration
% This script is merely a wrapper to loop over participants to register the
% EVC mask from BV

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output=[];here=cd;

% ROI labels
roi_labels={'v1_rh';'v1';'v2';'v3'};

which_sub=[6];
%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    % Loop through ROIS
    for cROI=1:numel(roi_labels)
        roi_name=roi_labels{cROI};
        ['Starting ', roi_name]
        
        %% Register
        VMRmaskToNii(cSub, sufs, sub_code, roi_name);
        
    end
    
    if cSub==6
        downsample_mask_sub6(cSub)
    end
end