function feedbes_aggregate_from_ROI(which_sub, glm)
% I'm taking here the results from the by-ROI output files from
% the decoding and creating a more comprehensible structure.

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

ROI_labels={'v1_rh'; 'v1_fov';'v1_periph'; 'v2_fov'; 'v2_periph'; 'hc';'vmpfc_cortex'; 'LOC_neurosynth'; 'precuneus_neurosynth'; 'hc_left'; 'hc_right'};
anal_tag={'diff scn-diff obj','diff scn-same obj','objects','ObjsCorr','XC',...
    'diff scn-diff obj sem','diff scn-same obj sem','objects sem','objsCorr sem','XC_sem'};
for cSub=1:numel(which_sub)
    sub_lab{cSub}=num2str(which_sub(cSub));
end

%% Loop through subjects
c=0;
for cSub=which_sub
    c=c+1;
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    sprintf(['*****************************************\n',...
        'Aggregating %s...'],sub_code)
    
    for cROI=2:length(ROI_labels)
        for cAnal=[2,3,5,7,8,10]
            
            % Load results
            load([sufs.outputs, 'tdt_eye_', glm, '/', ROI_labels{cROI}, '_', ...
                num2str(cAnal), '_results.mat'])
            
            % Get only relevant-info
            nPairs=length(roi_data);
            for cPairs=1:nPairs
                pairs_acc(cPairs)=(roi_data{cPairs}.accuracy_minus_chance.output+50)/100;
                %                 if cROI<6
                %                 pairs_perm(cPairs)=roi_data{cPairs}.p_perm;
                %                 end
            end
            
            % Store it in a structure with Analysis as the higher level. Right
            % below there's a subjects X ROI matrix. This is already
            % averaged across pairs.
            data{cAnal}(c,cROI)=mean(pairs_acc);
            
            % Store permutation results as well
            %             if cROI<6;perm_results{cAnal}(c,cROI)=mean(pairs_perm);end
            
        end
    end
end

% Create summary matrix by averaging across subjects
for cAnal=[2,3,5,7,8,10]
    summ_matrix(cAnal,:)=mean(data{cAnal},1);
end

% Create summary table
summ_table=array2table(summ_matrix, 'VariableNames', ROI_labels, ...
    'RowNames', anal_tag);

% Save summary table
writetable(summ_table, [output_dir, 'summary_table.csv'], 'WriteRowNames', 1)

% Create a full results table for stats
for cAnal=[2,3,5,7,8,10]
    results_matrix=data{cAnal};
    res_table=array2table(results_matrix, 'VariableNames', ROI_labels, ...
        'RowNames', sub_lab);
    writetable(res_table, [output_dir, anal_tag{cAnal}, '_results.csv'], 'WriteRowNames', 1)
    
end

% Save
save([output_dir, glm, '_results_clean.mat'], 'data')