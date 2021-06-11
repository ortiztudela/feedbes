function glm_LSS_SPM(which_sub)
% FORMAT images = glm_LSS_SPM_updated(subject, spmDir, outputdir, includeConditions, settings)
% This function takes an existing first-level SPM.mat file uses it to
% create one of two possible models: multi-regressor and multi-model.
% The multi-regressor approach estimates a single model with all trials
% represented by individual regressors. The multi-model approach estimates
% a model for each individual trial, setting the first regressor to the
% individual trial and all other regressors to be the same as the original
% model. Beta images are then moved and renamed in a single betas
% directory. The multi-regressor approach is similar to that described in
% Rissman et al. 2004 NI, and the multi-model approach is similar to the
% LS-S approach described in Turner et al. 2012 NI.
% This function is integrated with newLSS_correlation for beta-series
% functional connectivity with the multi-model approach through
% batch_newLSS.
%
%
% Inputs:
% subject:               Subject ID. String.
% spmDir:                Path to folder containing SPM.mat file. String.
% outputdir:                Path to output directory, where generated files
%                        will be saved. String.
% ignoreConditions:      Conditions to be ignored. Set to NONE if you do
%                        not want to ignore any conditions. Cell array of
%                        strings.
% settings:              Additional settings. Structure.
% settings.overwrite:    Overwrite any pre-existing files (1) or not (0).
%                        Double.
% settings.deleteFiles:  Delete intermediate files (1) or not (0). Double.
%
%
% Requirements: SPM8
%
% Setting the 'estimate' flag to a non-zero value will automatically
% estimate the newly-generated SPM.mat file.
%
%
% Created by Maureen Ritchey 121010
% Modified by Taylor Salo 140806-141216 according to adjustments suggested
% by Jeanette Mumford. LS-S now matches Turner et al. 2012 NI, where the
% design matrix basically matches the original design matrix (for a given
% block), except for the single trial being evaluated, which gets its own
% regressor. The final matrix will have as many regressors as the LSU one +
% the single trial evaluated. This controls for between classes differences
% in the residuals (see Turnet et al., 2012, NI).

% Modified by Javier Ortiz-Tudela 02.04.2020 To remove multi-regressor
% approach.
hhlr=0;
tic
%% Set up some parameters
discard_mm_files=1;
overwrite=1;
estimate=1;
sprintf('launching script')
%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
    %     main_folder = '/media/javier/Data/home_office/FeedBES';
else
    if hhlr
        main_folder= '/scratch/brainimage/ortiz/transfer_data/'
    else
        main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
    end
end
addpath('/mnt/md0/2_Analysis_Folder/PIVOTAL/FeedBES/analysis_scripts/spm8')
addpath([main_folder, '/analysis_scripts/clean/_functions'])

% Loop through participants
for cSub = which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    if cSub~=6
        space = 'T1w';
    else
        space = 'MNI152NLin2009cAsym';
    end
    
    %% MAIN CODE
    % Load pre-existing SPM file containing model information
    fprintf('\nLoading previous model for %s:\n%s\n', sub_code, [sufs.outputs, 'LSU_eye/SPM.mat']);
    if exist([sufs.outputs 'LSU_eye/SPM.mat'],'file')
        OrigSpm = load([sufs.outputs 'LSU_eye/SPM.mat']);
    else
        error('Cannot find SPM.mat file.');
    end
    
    %find or create the output directory for the single-trial model
    outputdir = [sufs.spm, 'LSS_eye/'];
    if ~exist(outputdir,'dir')
        fprintf('/nCreating directory:/n%s/n',outputdir);
        mkdir(outputdir)
    end
    
    % Get model information from SPM file
    fprintf('\nGetting model information...\n');
    files = OrigSpm.SPM.xY.P;
    % Replace old root dir in case this script is running in a different
    % computer from the one that created the original SPM (LSU).
    for i=1:length(files)
        ind=strfind(files(i,:), 'fmriprep');
        ind2=strfind(sufs.brain, 'fmriprep')-1;
        tmp(i,:)=[sufs.brain(1:ind2), files(i,ind:end)];
    end
    files = tmp;
    
    fprintf('Modeling %i timepoints across %i sessions.\n', size(files, 1), length(OrigSpm.SPM.Sess));
    
    % Make trial directory
    betaDir = [outputdir 'betas/'];
    if ~exist(betaDir, 'dir')
        mkdir(betaDir)
    end
    
    % The fun begins here
    spm_jobman('initcfg')
    spm('defaults', 'FMRI');
    spm_get_defaults('cmdline',true); % No graphical output
    parpool  % Start parallel processing
    
    % Loop across sessions (runs)
    for cRun = 1:length(OrigSpm.SPM.Sess)
        ['Starting run ', num2str(cRun), ' of subject ', num2str(cSub)]
        ['*************************************************************']
        ['*************************************************************']
        rows = OrigSpm.SPM.Sess(cRun).row;
        sessFiles = files(rows', :);
        sessFiles = cellstr(sessFiles);
        covariates = OrigSpm.SPM.Sess(cRun).C.C;
        originalNames = cell(1, length(OrigSpm.SPM.Sess(cRun).U));
        originalOnsets = cell(1, length(OrigSpm.SPM.Sess(cRun).U));
        originalDurations = cell(1, length(OrigSpm.SPM.Sess(cRun).U));
        for cCond = 1:length(OrigSpm.SPM.Sess(cRun).U)
            originalNames{cCond} = OrigSpm.SPM.Sess(cRun).U(cCond).name{1};
            originalOnsets{cCond} = OrigSpm.SPM.Sess(cRun).U(cCond).ons;
            originalDurations{cCond} = OrigSpm.SPM.Sess(cRun).U(cCond).dur;
        end
        [lssNames, lssOnsets, lssDurations] = lssMakeVectors(originalNames, originalOnsets, originalDurations, originalNames);
        includeConditions=originalNames;
        
        % Loop across conditions
        parfor cCond = 1:length(originalNames)% Turn this one into a parfor
            
            % Initialize
            beta_info{cCond}={};
            
            % Set up a model for each individual trial.
            for cRep = 1:length(lssOnsets{cCond}) 
                singleName = lssNames{cCond}{cRep}{1};
                names = lssNames{cCond}{cRep};
                onsets = lssOnsets{cCond}{cRep};
                durations = lssDurations{cCond}{cRep};
                
                % Make trial directory
                trialdir = [betaDir '../run' sprintf('%01d', cRun) '/' singleName ];
                if ~exist(trialdir,'dir')
                    mkdir(trialdir)
                end
                
                % Get names for outputing
                curr_name = [OrigSpm.SPM.Sess(cRun).U(cCond).name{1} '_' num2str(cRep)];
                curr_cond=str2double(OrigSpm.SPM.Sess(cRun).U(cCond).name{1});
                currinfo = {cRun curr_cond cRep length(OrigSpm.SPM.Sess(cRun).U(cCond).ons(cRep)) curr_name trialdir ['RUN' num2str(cRun) '_' curr_name '.img']};
                
                % Store info independently of other iterations
                beta_info{cCond}=[beta_info{cCond};currinfo];
                
                % Save regressor onset files
                regFile = [trialdir '/st_regs.mat'];
                parsave(regFile, names, onsets, durations);
                
                covFile = [trialdir '/st_covs.txt'];
                dlmwrite(covFile, covariates, '\t');
                
                % Run matlabbatch to create new SPM.mat file using SPM batch tools
                if overwrite || ~exist([trialdir '/beta_0001.img'], 'file')
                    
                    % Create matlabbatch for creating new SPM.mat file
                    matlabbatch = createSpmBatch(trialdir, OrigSpm.SPM);
                    matlabbatch = addSessionToBatch(matlabbatch, 1, sessFiles, regFile, covFile, OrigSpm.SPM);
                    
                    fprintf('\nCreating SPM.mat file:\n%s\n\n', [trialdir '/SPM.mat']);
                    spm_jobman('serial', matlabbatch);
                else
                    fprintf('\n%s already exists; skipping to next\n%s\n\n', [trialdir '/SPM.mat']);
                end
                
                if estimate
                    fprintf('\nEstimating model from SPM.mat file.\n');
                    spmFile = [trialdir '/SPM.mat'];
                    matlabbatch = estimateSpmFile(spmFile);
                    spm_jobman('serial', matlabbatch);
                    
                    % Copy first beta image to beta directory
                    NewSpm = load(spmFile);betaFile=[];
                    for mBeta = 1:length(NewSpm.SPM.Vbeta)
                        if ~isempty(strfind(NewSpm.SPM.Vbeta(mBeta).descrip, singleName))
                            betaFile = [NewSpm.SPM.Vbeta(mBeta).fname];
                            break
                        end
                    end
                    
                    % Get new beta name (in case we figure out how to
                    % output niftis from SPM estimate)
                    betaFileName=sprintf('RUN%d_%s', cRun, curr_name);
                    if strfind(betaFile, '.img')
                        system(['cp ' trialdir '/' betaFile ' ' betaDir betaFileName, '.img']);
                        system(['cp ' trialdir '/' betaFile(1:end-4) '.hdr ' betaDir betaFileName, '.hdr']);
                    elseif strfind(betaFile, '.nii')
                        system(['cp ' trialdir '/' curr_name '.nii ' betaDir betaFileName, '.nii']);
                    end
                    
                    % Discard extra files, if desired.
                    if discard_mm_files
                        system(['rm -rf ' trialdir]);
                    end
                end
            end
        end
        
        % Store run information
        temp=[];
        for cCond=1:size(beta_info,2)
            temp=[temp; beta_info{cCond}];
        end
        trialinfo{cRun}=temp;
    end
    
    % Save beta information
    clear temp
    temp={'run_number', 'condition', 'repetition', 'nofonsets', 'betaname', 'trialdir', 'filename'};
    for cRun=1:4
        temp=[temp;trialinfo{cRun}];
    end
    c=0;clear temp2
    for i=1:size(temp,1)
        temp2{i}=c;c=c+1;
    end
    temp2=temp2';temp2{1}='beta_number';
    trialinfo=[temp2,temp];
    
    infofile = [betaDir sub_code '_beta_info.mat'];
    save(infofile,'trialinfo');
    
    % Close parallel processing
    delete(gcp('nocreate'))
    toc
    clear SPM
    
end


end

%% SUBFUNCTIONS
function matlabbatch = createSpmBatch(outputdir, SPM)
% FORMAT matlabbatch = createSpmBatch(outputdir, SPM)
% Subfunction for initializing the matlabbatch structure to create the SPM
% file.
%
% 140311 Created by Maureen Ritchey
matlabbatch{1}.spm.stats.fmri_spec.dir = {outputdir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = SPM.xBF.UNITS;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = SPM.xY.RT;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = SPM.xBF.T;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = SPM.xBF.T0;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = SPM.xBF.Volterra;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
if isempty(SPM.xM.VM)
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
else
    matlabbatch{1}.spm.stats.fmri_spec.mask = {SPM.xM.VM.fname};
end
matlabbatch{1}.spm.stats.fmri_spec.cvi = SPM.xVi.form;
end

function matlabbatch = addSessionToBatch(matlabbatch, iSess, sessFiles, regFile, covFile, SPM)
% FORMAT matlabbatch = addSessionToBatch(matlabbatch, iSess, sessFiles, regFile, covFile, SPM)
% Subfunction for adding sessions to the matlabbatch structure.
%
%
% 140311 Created by Maureen Ritchey
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).scans = sessFiles; %fix this
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).multi = {regFile};
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).multi_reg = {covFile};
matlabbatch{1}.spm.stats.fmri_spec.sess(iSess).hpf = SPM.xX.K(iSess).HParam;
end

function matlabbatch = estimateSpmFile(spmFile)
% FORMAT matlabbatch = estimateSpmFile(spmFile)
% Subfunction for creating a matlabbatch structure to estimate the SPM
% file.
%
%
% 140311 Created by Maureen Ritchey
matlabbatch{1}.spm.stats.fmri_est.spmmat = {spmFile};
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
end

function [lssNames, lssOnsets, lssDurations] = lssMakeVectors(originalNames, originalOnsets, originalDurations, includeConditions)
% FORMAT [lssNames, lssOnsets, lssDurations] = lssMakeVectors(originalNames, originalOnsets, originalDurations, includeConditions)
% Uses SPM-format vectors (in variables corresponding to names, onsets, and
% durations) to create cell arrays of names, onsets, and durations for each
% LS-S model for conditions of interest.
%
%
% input
% originalNames:        Cell array of condition names for a single block.
% originalOnsets:       Cell array of trial onset vectors for a single block.
% originalDurations:    Cell array of trial duration vectors for a single block.
% includeConditions:    A cell array of events we wish to model with the
%                       beta LSS method.
%
% output
% lssNames:             Cell array of LS-S condition names for a single
%                       block. Format lssNames{includedCondition}{conditionName}
% lssOnsets:            Cell array of LS-S condition onsets for a single
%                       block. Format lssOnsets{includedCondition}{trialVersion}(trial)
% lssDurations:         Cell array of LS-S condition durations for a single
%                       block. Format lssDurations{includedCondition}{trialVersion}(trial)
for iCond = 1:length(includeConditions)
    % Determine where conditions of interest are in vectors.
    % Setdiff reorders conditions, otherConditions must be reordered.
    otherConditionsIdx = ~strcmp(includeConditions{iCond}, originalNames);
    [otherConditions, originalOrder] = setdiff(originalNames, includeConditions{iCond});
    [~, sortedOrder] = sort(originalOrder);
    otherConditions = otherConditions(sortedOrder);
    includeConditionIdx = find(~otherConditionsIdx);
    
    % Check that condition of interest has more than one trial.
    % If condition A only has one trial, you don't need both ConditionA_001
    % and Other_ConditionA, because Other_ConditionA would be empty.
    if ~isempty(setdiff(originalOnsets{includeConditionIdx}, originalOnsets{includeConditionIdx}(1)))
        for jOnset = 1:length(originalOnsets{includeConditionIdx}),
            % Create list of condition names
            % (e.g. ConditionA_001, Other_ConditionA, ConditionB, ConditionC, etc.)
            lssNames{iCond}{jOnset} = [{[originalNames{includeConditionIdx} '_' sprintf('%03d', jOnset)]...
                ['Other_' originalNames{includeConditionIdx}]}...
                otherConditions];
            
            % Single trial
            lssOnsets{iCond}{jOnset}{1} = originalOnsets{includeConditionIdx}(jOnset);
            lssDurations{iCond}{jOnset}{1} = originalDurations{includeConditionIdx}(jOnset);
            
            % Other trials of same condition
            lssOnsets{iCond}{jOnset}{2} = originalOnsets{includeConditionIdx};
            lssOnsets{iCond}{jOnset}{2}(jOnset) = [];
            lssDurations{iCond}{jOnset}{2} = originalDurations{includeConditionIdx};
            lssDurations{iCond}{jOnset}{2}(jOnset) = [];
            
            % Other conditions
            counter = 3; % A counter adjusts around the skipped condition.
            for kCond = find(otherConditionsIdx)
                lssOnsets{iCond}{jOnset}{counter} = originalOnsets{kCond};
                lssDurations{iCond}{jOnset}{counter} = originalDurations{kCond};
                counter = counter + 1;
            end
        end
    else
        % Single trial
        lssNames{iCond}{1} = [{[originalNames{includeConditionIdx} '_' sprintf('%03d', 1)]} otherConditions];
        lssOnsets{iCond}{1}{1} = originalOnsets{includeConditionIdx}(1);
        lssDurations{iCond}{1}{1} = originalDurations{includeConditionIdx}(1);
        
        % Other conditions
        conditionCounter = 2; % A counter adjusts around the skipped condition.
        for kCond = find(otherConditionsIdx)
            lssOnsets{iCond}{1}{conditionCounter} = originalOnsets{kCond};
            lssDurations{iCond}{1}{conditionCounter} = originalDurations{kCond};
            conditionCounter = conditionCounter + 1;
        end
    end
end
end

function parsave(outFile, names, onsets, durations)
save(outFile, 'names', 'onsets', 'durations');
end