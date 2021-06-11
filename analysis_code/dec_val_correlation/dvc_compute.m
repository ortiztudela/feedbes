% Compute correlation between decision values and beta series from ROIs
clear
close all

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'),'ortiz')
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath('/home/javier/pepe/2_Analysis_Folder/_common_software/spm12')
%% Experiment info

% Who?
which_sub=[1:5,7:30];

% When?
nRuns=4;

% Decision values from where?
class_ROIs={'v1_fov'; 'v1_periph'; 'v2_fov'; 'v2_periph'};

% Where (sources)?
source_ROIs={'vmpfc_cortex';'hc'};

%% Loop through subjects
for cSub=which_sub
    corr_run=[];
    out_mat=[];
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    space = 'MNI152NLin2009cAsym';
    ['Starting sub ', num2str(cSub)]
    
    % Load current subject's parameters
    load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat'])
    
    %%%%%%%% First  we need the trial info
    %%%%%%%%
    conv_labels=[];
    for cRun=1:4
        
        % Get current subject's run data
        load([sufs.beh, 'feedBES_', num2str(cSub), '_run', num2str(cRun), '_data.mat'])
        
        % Turn text labels into numbers
        conv_labels=[conv_labels; feedBES_conv_labels(cSub, p.pred.scn_labels(:,cRun))];
    end
    %%%%%%%%
    %%%%%%%%
    
    
    %% Loop through classification regions
    for cROI=2%1:length(class_ROIs)
        
        % Load seeds timecourse (betas)
        %         'Loading EVC dec values'
        %%%%%%% This is an unnecessarily complex way of doing it. I
        %%%%%%% should probably sort the betas somewhere else and
        %%%%%%% just load them from here. Future Javi will take
        %%%%%%% care of that.
        
        %% Now we need the classifier info
        % Load TDT output
        load([sufs.outputs, 'tdt_eye_LSS/results.mat'])
        
        for cAnal=[3,8]
            
            % Get pair info
            nPairs=length(output{cAnal}{cROI});
            mat=zeros(4,24,nPairs);mat(mat==0)=NaN;
            beta_mat=[];
            % Memory condition
            if cAnal==3;mem_cond=0;mem_lab='epi';else;mem_cond=1;mem_lab='sem';end
            sorted_dec=[];
            
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
                    rep_num(cBeta)=str2num(beta_info{cBeta}(ind+7+mem_cond));
                end
                if cSub==13
                    rep_nbr=[1:8,1:8,1:8,1:8,9:16,9:16,9:16,9:16,17:24,17:24,17:24,17:24,25:32,25:32,25:32,25:32];
                else
                    rep_nbr=[1:6,1:6,1:6,1:6,7:12,7:12,7:12,7:12,13:18,13:18,13:18,13:18,19:24,19:24,19:24,19:24];
                end
                % Arrange data into a condition by repetition by pair matrix
                for i=1:length(dec_val)
                    mat(trial_cond(i),rep_nbr(i),cPair)=dec_val(i);
                    beta_mat{trial_cond(i),rep_nbr(i)}=beta_info{i};
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
            clear sorted_beta
            for cCond=curr_cond
                ind=find(conv_labels==cCond);
                sorted_dec(ind)=av_mat(cCond,:);
                sorted_beta(ind)=beta_mat(cCond,:);
            end
            
            %% Split by runs
            sorted_dec=sorted_dec(sorted_dec~=0);
            c=1;temp=[];
            for i=1:length(sorted_beta)
                if ~isempty(sorted_beta{i})
                    temp{c}=sorted_beta{i};
                    c=c+1;
                end
            end
            sorted_beta=temp;
            dec=reshape(sorted_dec,[length(sorted_dec)/4,4]);
            betas=reshape(sorted_beta,[length(sorted_beta)/4,4]);
            
            %% Loop through sources
            for cSource=1:length(source_ROIs)
                
                %% Loop through runs
                temp=[];
                for cRun=1:nRuns
                    source_series=[]; dec_values=[];
                    
                    %%%%%%%% Now we select the betas and decs for this run
                    beta_files=betas(:,cRun);
                    dec_values=dec(:,cRun);
                    
                    % Load ROI timecourse (betas)
                    %                 'Loading sources timecourse (betas)'
                    %%%%%%%% We can use the extract_beta_series function for this.
                    %%%%%%%%
                    mask_name = [sufs.mask, sub_code, '_', source_ROIs{cSource}, '_correg.nii.gz'];
                    gunzip(mask_name);
                    source_mask=[sufs.mask, sub_code, '_', source_ROIs{cSource}, '_correg.nii'];
                    source_series=extract_beta_series(beta_files,source_mask);
                    
                    %%%%%%%
                    %%%%%%%
                    
                    %% Compute correlation and store it into a matrix
                    corr_run(cROI,cSource,cRun)= corr2(source_series,dec_values');
                    
                    % Create plot
                    [sorted, ind]=sort(source_series);dec_sort=dec_values(ind);
                    subplot(5,6,cSub), plot(sorted, ind', '.')
                    
                    % Run mat
                    temp(:,:,cRun)=[repmat(cSub,length(source_series),1),...
                        repmat(cSource,length(source_series),1),...
                        source_series', dec_values, ...
                        repmat(cRun,length(source_series),1)];
                    
                end
                % Final mat
                out_mat=[out_mat;reshape(temp,size(temp,1)*4,size(temp,2))];
            end
            
            % Average across runs
            corr_mat(:,:)=mean(atanh(corr_run),3);
            
            %% Save results
            save([sufs.dec_corr, mem_lab, '_corr_matrix.mat'], 'corr_mat')
            csvwrite([sufs.dec_corr, mem_lab, '_fulldata.csv'], out_mat)
        end
    end
end