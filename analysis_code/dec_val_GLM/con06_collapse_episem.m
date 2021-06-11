%% FeedBES. FeedBack signals from Episodic and Semantic memories"
% author: "Javier Ortiz-Tudela" (Goethe Uni)
% ---
% *Contact: ortiztudela@psych.uni-frankfurt.de*

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
mem_label={'epi';'sem'};
TR = 800;
cAnal=3;
which_sub=[1:5,7:30];

which_sub=19
% Which classification?
if cAnal==2; class_label='scn';elseif cAnal==3; class_label='obj';end

for cSub = which_sub
    close all
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);% event file
    
    % First let's load the decision values for the separate conditions
    load([sufs.outputs, 'tdt_eye_LSS/v1_periph_obj_dec_values.mat'], 'dec')
    
    % Load current subject's parameters
    load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat'])
    
    % Get nVols
    if cSub==13
        nTR=975;
    else
        nTR=735;
    end
    run_duration= nTR*TR; % in milliseconds
    
    %% start looping over runs
    for cRun = 1:4
        
        
        names=[];onsets=[];durations=[]; %initialize the variables
        
        % Get current subject's run data %episodic/semantic
        load([sufs.beh, 'feedBES_', num2str(cSub), '_run', num2str(cRun), '_data.mat'])
        
        %% Get episodic and semantic onsets
        load([sufs.beh, 'spm_episem_run', num2str(cRun), '.mat'])
        
        % Turn into milliseconds
        onsets{1}=floor(onsets{1}*1000);
        onsets{2}=floor(onsets{2}*1000);
        
        % Round to nearest integer
        onsets{1}=round(onsets{1});
        onsets{2}=round(onsets{2});
        
        % Collapse onsets
        coll_onsets=[onsets{1};onsets{2}];
        
        % Collaps dec values
        coll_dec=[dec{cAnal}(:,1);dec{cAnal+5}(:,1)];
        
        % Sort by onset
        [coll_onsets,ind]=sort(coll_onsets);
        coll_dec=coll_dec(ind,1);
        
        %% Create onset vector of 1s
        ME = zeros(run_duration,1);          % creates a vector of zeros
        ME(coll_onsets)=1;
        
        %% Convolve onsets with HRF
        bf=(spm_hrf(.8));bf=resample(bf,1000,1); %in milliseconds
        cME = conv(bf,ME);      % convolve main effect with basis function
        cME = cME(1:run_duration);       % remove extra values added by convolution
        cME = cME/max(cME);     % scale to a max of 1 (for visual comparison)
        
        
        %% Plot steps
        figure
        subplot(2,2,1), plot(ME);title('onset vector');hold on
        subplot(2,2,1), plot(cME, 'Color', 'r');
        
        %% Create modulator regressor
        
        parameter = coll_dec;              % the parameter (size corresponds to onsets) where do these numbers come from?
        % Create onset vector of 1s
        PM = zeros(run_duration,1);                      % creates a vector of 100 TRs (all zeros for now)
        PM(coll_onsets) = parameter/max(parameter);  % puts same scale as main effect
        
        %% Convolve onsets with HRF
        bf=spm_hrf(.8);bf=resample(bf,1000,1); %in milliseconds
        cPM = conv(bf,PM);      % convolve main effect with basis function
        cPM = cPM(1:run_duration);       % remove extra values added by convolution
        cPM = cPM/max(cPM);     % scale to a max of 1 (for visual comparison)
        
        %% Plot steps
        subplot(2,2,2), plot(PM);title('dec values');hold on
        subplot(2,2,2), plot(cPM, 'Color', 'r');
        
        %% De-correlate PM
        oparameter = parameter - mean(parameter);   % de-mean the parameter
        oPM = zeros(run_duration, 1);                        % another vector of zeros
        oPM(coll_onsets) = oparameter/max(oparameter);   % re-scale
        coPM = conv(bf,oPM);                        % convolve
        coPM = coPM(1:run_duration);                         % remove extra values
        coPM = coPM/max(coPM);                      % re-scale
        
        %% Plot steps
        subplot(2,2,3), plot(cME, 'Color', 'b');hold on
        subplot(2,2,3), plot(cPM, 'Color', 'r');title(['Pred correlation: ', num2str(corr(cME,cPM))])
        subplot(2,2,4), plot(cME, 'Color', 'b');hold on
        subplot(2,2,4), plot(coPM, 'Color', 'r');title(['Pred correlation: ', num2str(corr(cME,coPM))])
        
        %% Cut to volumes
        coPM = coPM(1:TR:end);
        
        %% Save output
        % To .mat
        save([sufs.connect, 'coll_dec_values_',class_label, '_run', num2str(cRun),'.mat'], 'coPM')
        temp(:,1)=coPM;
        
        
        % And save to text file with the rest of the covariates
        cov=readtable([sufs.brain, 'ses-02/func/', sub_code, '_task-feedBES_run-4_covar.txt']);
        cov = addvars(cov,temp(:,1));
        writetable(cov, [sufs.connect, 'coll_covar_dec_values_', class_label, '_run', num2str(cRun),'.txt'],'WriteVariableNames',0)
        temp=[];
    end
    % Save figure
    %     saveas(gcf, [sufs.figures, 'parametric_modulation.jpg'])
    close all
    % Print message on the screen
    fprintf(['subject ' num2str(cSub,'%.2d') ' done\n'])
end