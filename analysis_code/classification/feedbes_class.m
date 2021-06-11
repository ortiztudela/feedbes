function results=feedbes_class(sufs, sub_code,glm,mask,label1,label2,tag,where)
% 24/09/2020. JOT puts this together to perform decoding from eye movements
% cleaned data.

%% Add necessary paths
% Add decoding toolbox and your favorite software (SPM or AFNI)
addpath([sufs.main,'/analysis_scripts/decoding_toolbox_v3.997'])
addpath([sufs.main, '/../../_common_software/spm12'])

% Set the filepath where your SPM.mat and all related betas are, e.g. 'c:\exp\glm\model_button'
if strcmpi(glm, 'LSS')
    beta_loc = [sufs.main, '/spm_analyses/',sub_code,'/LSS_eye'];
    output_dir = [sufs.main,'/outputs/',sub_code,'/tdt_eye_LSS'];
elseif strcmpi(glm, 'LSU')
    beta_loc = [sufs.main, '/outputs/',sub_code,'/LSU_eye'];
    output_dir = [sufs.main, '/outputs/',sub_code,'/tdt_eye_LSU'];
elseif strcmpi(glm, 'LSU_objects')
    beta_loc = [sufs.main, '/outputs/',sub_code,'/LSU_objects'];
    output_dir = [sufs.main, '/outputs/',sub_code,'/tdt_LSU_objects'];
elseif strcmpi(glm, 'LSU_objects_corr')
    beta_loc = [sufs.main, '/outputs/',sub_code,'/LSU_objects_corr'];
    output_dir = [sufs.main, '/outputs/',sub_code,'/tdt_LSU_objects_corr'];
end
if ~exist(output_dir)
    mkdir(output_dir)
end

%% Define parameters of the analysis
% Load TDT defaults
cfg = decoding_defaults;

% Additional stuff
cfg.analysis = where;
cfg.searchlight.radius = 3; % use searchlight of radius 3 (by default in voxels), see more details below
cfg.results.overwrite=1;
cfg.results.write=1;
cfg.verbose = 0; % you want all information to be printed on screen
cfg.plot_selected_voxels = 0; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...
cfg.plot_design = 0;
cfg.decoding.use_kernel=1;
cfg.results.dir = output_dir;  %output directory where data will be saved
cfg.results.output = {'decision_values', 'accuracy_minus_chance'};

%% Where?
% Set the filename of your brain mask (or your ROI masks as cell matrix)
mask_name=fullfile([sufs.mask, sub_code, '_',mask,'_correg.nii.gz']);
if ~exist(mask_name(1:end-3))
    gunzip(mask_name)
end
cfg.files.mask = mask_name(1:end-3);

%% What?
% Set the label names to the regressor names which you want to use for
% decoding. Don't remember the names? -> run display_regressor_names(beta_loc)
labelname1 = label1;
labelname2 = label2;

%% How?
% Define the design and the cross validation scheme
if strcmpi(glm, 'LSS') % If doing LSS, do it manually
    cfg=update_cfg_LSS(sub_code,sufs,cfg,labelname1,labelname2,tag, 'eye');
elseif strcmpi(glm, 'LSU_objects')
    
    if mean(labelname1)==1.5
        labelname1=1;
    elseif mean(labelname1)==3.5
        labelname1=2;
    elseif mean(labelname1)==5.5
        labelname1=3;
    elseif mean(labelname1)==7.5
        labelname1=4;
    end
    if mean(labelname2)==1.5
        labelname2=1;
    elseif mean(labelname2)==3.5
        labelname2=2;
    elseif mean(labelname2)==5.5
        labelname2=3;
    elseif mean(labelname2)==7.5
        labelname2=4;
    end
    
    % The following function extracts all beta names and corresponding run
    % numbers from the SPM.mat
    regressor_names = design_from_spm(beta_loc);
    % Extract all information for the cfg.files structure (labels will be [1 -1] )
    cfg = decoding_describe_data(cfg,{num2str(labelname1) num2str(labelname2)},[1 -1],regressor_names,beta_loc);
    % This creates the leave-one-run-out cross validation design:
    cfg.design = make_design_cv(cfg);
    
elseif strcmpi(glm, 'LSU_objects_corr')
    
    if mean(labelname1)==2
        labelname1=1;
    elseif mean(labelname1)==3
        labelname1=2;
    elseif mean(labelname1)==6
        labelname1=3;
    elseif mean(labelname1)==7
        labelname1=4;
    else
        keyboard
    end
    if mean(labelname2)==2
        labelname2=1;
    elseif mean(labelname2)==3
        labelname2=2;
    elseif mean(labelname2)==6
        labelname2=3;
    elseif mean(labelname2)==7
        labelname2=4;
    else
        keyboard
    end
    
    % The following function extracts all beta names and corresponding run
    % numbers from the SPM.mat
    regressor_names = design_from_spm(beta_loc);
    % Extract all information for the cfg.files structure (labels will be [1 -1] )
    cfg = decoding_describe_data(cfg,{num2str(labelname1) num2str(labelname2)},[1 -1],regressor_names,beta_loc);
    % This creates the leave-one-run-out cross validation design:
    cfg.design = make_design_cv(cfg);
    
    
else
    if numel(labelname1)==1 % If doing scenes (i.e., 1 scene per label)
        % The following function extracts all beta names and corresponding run
        % numbers from the SPM.mat
        regressor_names = design_from_spm(beta_loc);
    else % If doing objects (i.e., 2 scenes per label)
        regressor_names=update_cfg_objects(sub_code,sufs,cfg,glm,labelname1,labelname2);
        labelname1=1001;labelname2=1002;
    end
    
    % Extract all information for the cfg.files structure (labels will be [1 -1] )
    cfg = decoding_describe_data(cfg,{num2str(labelname1) num2str(labelname2)},[1 -1],regressor_names,beta_loc);
    % This creates the leave-one-run-out cross validation design:
    cfg.design = make_design_cv(cfg);
end

%% And run!
results = decoding(cfg);
results.mask_label=mask;
results.files=cfg.files;

% Permutation test
do_perm=0;
if do_perm
    true_test=cfg.design.label(cfg.design.test==1); % Storing the true labels here to enable their use in the permutation test
    cfg = rmfield(cfg,'design'); % this is needed if you previously used cfg.
    cfg.design.function.name = 'make_design_cv';
    n_perms = 1000;  % pick a reasonable number, the function might compute less if less are available
    combine = 0;
    designs=[];
    designs = make_design_permutation(cfg,n_perms,combine);
    cfg.verbose=0;
    perm_cfg=[];
    for i_perm = 1:n_perms
        ['Preparing permutation ', num2str(i_perm)]
        perm_cfg{i_perm}=cfg;
        if length(designs{i_perm}.label(designs{i_perm}.test==1))~=length(true_test)
            keyboard
        end
        designs{i_perm}.label(designs{i_perm}.test==1)=true_test; % Use true test labels
        perm_cfg{i_perm}.design = designs{i_perm};
        perm_cfg{i_perm}.results.dir = [sufs.outputs, mask, '_perm/pair_', sprintf('%d%d/%04d',label1, label2,i_perm)];
    end
    parfor i_perm = 1:n_perms
        ['Running permutation ', num2str(i_perm)]
        perm=decoding(perm_cfg{i_perm}); % run permutation
        perm_acc(i_perm)=perm.accuracy_minus_chance.output;
    end
    
    % Single subject stats
    results.p_perm=signrank(perm_acc,results.accuracy_minus_chance.output, 'tail', 'left');
    results.perm_acc=perm_acc;
    
    % Remove output files to save disk space
    'Cleaning up'
    system(['rm -rf ', sufs.outputs, mask, '_perm/pair_', sprintf('%d%d',label1, label2)]);
end

end