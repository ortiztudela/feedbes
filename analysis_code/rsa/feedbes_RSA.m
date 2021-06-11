function feedbes_RSA(sufs, sub_code, mask)
% 28/09/2020. JOT cleans this up to leave only the essential lines of code.

%% Define parameters of the analysis
% Load TDT defaults
cfg = decoding_defaults;
cfg.analysis = 'roi';

% Set the output directory where data will be saved
cfg.results.dir = [sufs.outputs '/tdt_RSA/',mask]; 

% Set the filepath where your SPM.mat and all related betas are
beta_loc = [sufs.outputs 'LSU_eye'];

%% Where?
% Set the filename of your brain mask (or your ROI masks as cell matrix)
mask_name=fullfile([sufs.mask, sub_code,'_', mask, '_correg.nii.gz']);
if ~exist(mask_name(1:end-3))
    gunzip(mask_name)
end
cfg.files.mask = mask_name(1:end-3);

%% What?
% Set the label names to the regressor names which you want to use for
% decoding. Don't remember the names? -> run display_regressor_names(beta_loc)
labelnames = [1:8,11:18];
labels = 1:length(labelnames);

% set everything to calculate (dis)similarity estimates
cfg.decoding.software = 'distance'; % the difference to 'similarity' is that this averages across data with the same label
cfg.decoding.method = 'classification'; % this is more a placeholder
cfg.decoding.train.classification.model_parameters = 'cveuclidean'; % cross-validated Euclidean after noise normalization
cfg.plot_selected_voxels = 0; % 0: no plotting, 1: every step, 2: every second step, 100: every hundredth step...
% Full dissimilarity matrix averaged across cross-validation iterations.
cfg.results.output = 'other_average';

% These parameters carry out the multivariate noise normalization using the
% residuals
cfg.scale.method = 'cov'; % we scale by noise covariance
cfg.scale.estimation = 'separate'; % we scale all data for each run separately while iterating across searchlight spheres
cfg.scale.shrinkage = 'lw2'; % Ledoit-Wolf shrinkage retaining variances

% Calculate residuals of the first-level (needed for the crossnobis 
% distance). 
[misc.residuals,cfg.files.residuals.chunk] = residuals_from_spm(fullfile(beta_loc,'SPM.mat'),cfg.files.mask); % this only needs to be run once and can be saved and loaded

%% Nothing needs to be changed below for standard dissimilarity estimates using all data

% The following function extracts all beta names and corresponding run
% numbers from the SPM.mat
regressor_names = design_from_spm(beta_loc);
LSS=1;
if LSS
    % LSS betas' names are
    % "RUN<run_nbr>_<condition_label>_<repetition_number>
    cfg=update_cfg_LSS_RSA(sub_code,sufs,cfg,labelnames, '');
else
    
    % Extract all information for the cfg.files structure (labels will be [1 -1] )
    cfg = decoding_describe_data(cfg,labelnames,labels,regressor_names,beta_loc);
end
% This creates a design in which cross-validation is done between the distance estimates
cfg.design = make_design_similarity_cv(cfg);
cfg.results.overwrite = 1;
% Run decoding
results = decoding(cfg,[],misc);