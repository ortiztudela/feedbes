% ---
% title: "FeedBES. FeedBack signals from Episodic and Semantic memories"
% author: "Javier Ortiz-Tudela" (Goethe Uni)
% ---
% *Contact: ortiztudela@psych.uni-frankfurt.de*
%
% *date: 20 10 2020*

% Pulls classifier decision values from TDT output and sorts them by trials
% rather than by betas to be able to include them as a parametric regressor
% in a full brain GLM
clear; close all
%% Add necessary paths
% Main folder.
if strcmpi(getenv('USERNAME'),'javier')
    samba_folder= '/home/javier/pepe/';
    spm_folder='/home/javier/pepe/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'), 'ortiz')
    spm_folder='/home/ortiz/DATA/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
else % Replace below with the paths for your computer
    samba_folder= 'smb://ntsamba1.server.uni-frankfurt.de/entwicklungspsychologie';
    spm_fodler='/Users/Nina/spm12'; %add path to my spm
    main_folder= [samba_folder, '/2_Student_Analysis/PIVOTAL/FeedBES'];
end
roi_labels={'v1_fov';'v1_periph';'v2_fov';'v2_periph';'vmpfc_neurosynth';'hc';'vmpfc_cortex'; 'LOC_neurosynth'; 'precuneus_neurosynth'; 'CA1';'DG'};%'ERC';'CA2'};

% Which subs?
which_sub=[1:5,7:30];

% Which classification?
obj_class=1;
if obj_class==0; class_label='scn';elseif obj_class==1; class_label='obj';end

% Loop through subjects
for cSub=which_sub
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    ['Starting ', sub_code]
    dec=[];
    for cAnal=[2,3,7,8]
        cROI=8;
        
        % Load current subject's parameters
        load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat'])
        
        %% Now we need the trial info
        % start looping over runs
        conv_labels=[];
        for cRun = 1:4
            
            % Get current subject's run data
            load([sufs.beh, 'feedBES_', num2str(cSub), '_run', num2str(cRun), '_data.mat'])
            
            % Turn text labels into numbers
            conv_labels=[conv_labels; feedBES_conv_labels(cSub, p.pred.scn_labels(:,cRun))];
            
        end
        
        %% Now we need the classifier info
        % Load TDT output
        load([sufs.outputs, 'tdt_eye_LSS/results.mat'])
        % Get pair info
        nPairs=length(output{cAnal}{cROI});
        if cAnal==2
            mat=zeros(8,24,nPairs);mat(mat==0)=NaN;
        elseif cAnal==3
            mat=zeros(4,24,nPairs);mat(mat==0)=NaN;
        end
        
        %         for mem_cond=0:1
        if cAnal<9;mem_cond=0;else;mem_cond=1;end%==1;cAnal=cAnal+5;end % Switch for semantic trials
        sorted_dec=zeros(384,1);
        
        % Get decision values by betas
        for cPair=1:nPairs
            
            pair_data=output{cAnal}{cROI}{cPair};
            
            dec_val=pair_data.decision_values.output{1};
            
            % Get beta info
            beta_info=pair_data.files.name;
            run_label=pair_data.files.chunk;
            for cBeta=1:length(beta_info)
                ind=strfind(beta_info{cBeta}, 'RUN');
                trial_cond(cBeta)=str2num(beta_info{cBeta}(ind+5:ind+5+mem_cond));
                %                 rep_nbr(cBeta)=str2num(beta_info{cBeta}(ind+7+mem_cond));
            end
            if cSub==13
                if cAnal==2
                    rep_nbr=[1:8,1:8,9:16,9:16,17:24,17:24,25:32,25:32];
                elseif cAnal==3
                    rep_nbr=[1:8,1:8,1:8,1:8,9:16,9:16,9:16,9:16,17:24,17:24,17:24,17:24,25:32,25:32,25:32,25:32];
                end
            else
                if cAnal==2
                    rep_nbr=[1:6,1:6,7:12,7:12,13:18,13:18,19:24,19:24];
                elseif cAnal==3
                    rep_nbr=[1:6,1:6,1:6,1:6,7:12,7:12,7:12,7:12,13:18,13:18,13:18,13:18,19:24,19:24,19:24,19:24];
                end
            end
            % Arrange dec into a condition by repetition by pair matrix
            for i=1:length(dec_val)
                mat(trial_cond(i),rep_nbr(i),cPair)=dec_val(i);
            end
        end
        
        % Average across pairs
        av_mat=nanmean(mat,3);
        
        %% Match with trial info
        if mem_cond==0
            curr_cond=1:8;
        else
            curr_cond=11:18;
        end
        for cCond=curr_cond
            ind=find(conv_labels==cCond);
            sorted_dec(ind)=av_mat(cCond,:);
        end
        
        %% Split by runs
        sorted_dec=sorted_dec(sorted_dec~=0);
        dec{cAnal}=reshape(sorted_dec,[length(sorted_dec)/4,4]);
    end
    %% Save output
    save([sufs.outputs, 'tdt_eye_LSS/', roi_labels{cROI}, '_', class_label, '_dec_values.mat'], 'dec')
    
end
