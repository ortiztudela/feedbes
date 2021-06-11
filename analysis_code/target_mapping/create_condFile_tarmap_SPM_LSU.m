% Creates conditions files (per run) for SPM
% Author: González-García (Ghent Uni)
% Modified: Ortiz-Tudela (Goethe Uni)

function create_condFile_tarmap_SPM_LSU(which_sub)
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end

for cSub = which_sub % start looping over participants
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    root_out = sufs.outputs; % folder where you want to store the output files
    
    % Load task outputs
    load([sufs.beh, 'feedBES_', num2str(cSub), '_mapping_data.mat']);
    load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat']);
    
    % Nombres de variables importantes names, duration onsets
    labels=unique(r.map.block_label);
    
    for i=1:length(labels)
        ind=strcmpi(r.map.block_label,labels{i});
        names{i}=labels{i};
        onsets{i}=r.trialOnset(ind)+4.8;
        durations{i}=[r.trialOffset(ind)-r.trialOnset(ind)];
        
    end
    
    % Save
    save([sufs.beh, 'spm_LSU_tarmap'],'onsets','names','durations')
    
    fprintf(['subject ' num2str(cSub,'%.2d') ' done\n'])
end
end
