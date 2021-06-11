function feedBES_launcher(which_sub, which_anal, glm, where) %% Memory-driven predictions project. Classification analyses.
%% ############## Experiment info ##############
%#######  Event-related design: 16 scenes and 4 objects.
% Pairing between scenes and objects is counterbalanced
% across participants. CB of labels is performed in the
% feedBES_desMat_runs script.

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output=[];

%% Where are we going to prerform the analysis?
if strcmpi(where, 'searchlight')
    roi_labels='GM';
elseif strcmpi(where, 'roi')
    roi_labels={'v1_fov';'v1_periph';'v2_fov';'v2_periph';'vmpfc_cortex';'LOC_neurosynth'};%; 'precuneus_neurosynth'; 'hc_left';'hc_right'};%'CA1';'DG'};%'ERC';'CA2'};
else
    error('Please, select either searchlight or roi as where argument')
end
nROIs=length(roi_labels);

%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    sprintf(['*****************************************\n',...
        'Starting classification of %s.'],sub_code)
    
    % Loop through analyses
    for cAnal=which_anal
        
        % Select which type of classification to perform in this loop
        [pairs, tag, nPairs]=feedBES_schema_class(cAnal);
        
        % Loop through rois
        for cROI=6%1:nROIs
            % Which mask?
            mask=roi_labels{cROI};
            
            %% Loop through the pairs to start classification
            % Select pairs according to the arrangement done above
            for cPair=1:nPairs
                if size(pairs,3)>1 % If doing objects or XC
                    output{cAnal}{cROI}{cPair}=feedbes_class(sufs, sub_code, glm, mask, pairs(1,:,cPair), pairs(2,:,cPair),tag,where);
                else % If doing scenes
                    output{cAnal}{cROI}{cPair}=feedbes_class(sufs, sub_code, glm, mask, pairs(cPair,1), pairs(cPair,2),tag,where);
                end
            end
            % Save this ROI output
            if ~exist([sufs.outputs, 'tdt_', glm, '/']);mkdir([sufs.outputs, 'tdt_', glm, '/']);end
            roi_data=output{cAnal}{cROI};
            save([sufs.outputs, 'tdt_', glm, '/', roi_labels{cROI}, '_', num2str(cAnal), '_results.mat'], 'roi_data')

        end
    end
    
    % Save this subject's output
    if ~exist([sufs.outputs, 'tdt_', glm, '/']);mkdir([sufs.outputs, 'tdt_', glm, '/']);end
    save([sufs.outputs, 'tdt_', glm, '/LOC_results.mat'], 'output')
end