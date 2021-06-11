%% FeedBES: Feedback from Episodic and Semantic memories
% Target mapping launcher

which_subs=[1];

% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end

addpath(genpath(['/home/javier/pepe/2_Analysis_Folder/_common_software/spm12']))

for cSub=which_subs
    ['Subject ', num2str(cSub)]
    
    'Creating event files...'
    create_condFile_tarmap_SPM_LSU(cSub)
    
    'Computing GLM...'
    glm_tarmap_SPM(cSub)
    
    'Contrasts...'
    contrast_tarmap_SPM(cSub)
    
    if cSub~=6
        cmd=sprintf('sh combine_tarmap_masks.sh %s %d %s', main_folder, cSub, 'v1');
        system(cmd);
    else
        
        % Threshold T maps from SPM
        cmd=sprintf('sh combine_tarmap_masks_sub6-1.sh %s %d %s', main_folder, cSub, 'v1');
        system(cmd);
        
        % Mask EVC ROIs with thresholded maps
        cmd=sprintf('sh combine_tarmap_masks_sub6.sh %s %d %s', main_folder, cSub, 'v1');
        system(cmd);
    end
    
    cmd=sprintf('sh combine_tarmap_masks.sh %s %d %s', main_folder, cSub, 'v2');
    system(cmd);
    
end
