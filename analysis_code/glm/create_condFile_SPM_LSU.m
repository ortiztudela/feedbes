% Creates conditions files (per run) for SPM
% Author: González-García (Ghent Uni)
% Modified: Ortiz-Tudela (Goethe Uni)

function create_condFile_SPM_LSU(which_sub)
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
    addpath('/home/ortiz/Documents/MATLAB/fmri_utils/');
end

for cSub = which_sub % start looping over participants
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    root_out = sufs.outputs; % folder where you want to store the output files
    
    conv_labels=[];
    for cRun = 1:4 % start looping over runs
        
        % Load task outputs
        load([sufs.beh, 'feedBES_', num2str(cSub), '_run', num2str(cRun),'_data.mat']);
        load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat']);
        
        % Nombres de variables importantes names, duration onsets
        labels=unique(p.pred.scn_labels);
        [~,conv_labels(:,cRun),~]=feedBES_desMat_runs(sufs, cSub, cRun, [], []);
        
        for i=1:length(labels)
            ind=strcmpi(p.pred.scn_labels(:,cRun),labels{i});
            tmp=conv_labels(ind,cRun);
            names{i}=num2str(unique(tmp)); % It is easier to use the numbers to deal with CB
            onsets{i}=r.trialOnset(ind)+4.8;
            durations{i}=[r.trialOffset(ind)-r.trialOnset(ind)];
        end
        
        % Save
        save([sufs.beh, 'spm_LSU_run' num2str(cRun)],'onsets','names','durations')
    end
    fprintf(['subject ' num2str(cSub,'%.2d') ' done\n'])
end
end