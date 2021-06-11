function [sufs, sub_code]=feedbes_getdir(main_folder, which_sub)
%% Get folder structure for this participant in feedBES

%% Folder names
sufs.BIDS = '/BIDS/';
sufs.beh = '/task_outputs/';
sufs.brain = '/preproc_data_hlr/fmriprep/';
sufs.mask = '/masks/';
sufs.retMap = '/BV_analyses/';
sufs.spm = '/spm_analyses/';
sufs.eyemov = '/eye_movements_analyses/';
sufs.hc = '/hc_highres/';
sufs.outputs = '/outputs/';
sufs.figures = '/figures/';
sufs.day1 = '/day1_outputs/';
sufs.post = '/postscan_outputs/';
sufs.dec_corr = '/dec_val_corr/';


%% Sub code
if which_sub<10
    sub_code=['sub-0', num2str(which_sub)];
else
    sub_code=['sub-', num2str(which_sub)];
end

%% Create subject folders names
sufs.BIDS=[main_folder,sufs.BIDS, sub_code,'/'];
sufs.beh=[main_folder,sufs.beh, sub_code,'/'];
sufs.brain=[main_folder,sufs.brain, sub_code,'/'];
sufs.mask=[main_folder,sufs.mask, sub_code,'/'];
sufs.retMap=[main_folder,sufs.retMap, sub_code,'/'];
sufs.spm=[main_folder,sufs.spm, sub_code,'/'];
sufs.eyemov=[main_folder,sufs.eyemov, sub_code,'/'];
sufs.hc=[main_folder,sufs.hc, sub_code,'/'];
sufs.outputs=[main_folder,sufs.outputs, sub_code,'/'];
sufs.figures=[main_folder,sufs.figures, sub_code,'/'];
sufs.day1=[main_folder,sufs.day1, sub_code,'/'];
sufs.post=[main_folder,sufs.post, sub_code,'/'];
sufs.main=main_folder;
sufs.funct=[main_folder, '/analysis_scripts/clean/_functions/'];
sufs.ppi=[sufs.outputs, 'PPI_results/'];
sufs.gppi=[sufs.outputs, 'gPPI/'];
sufs.connect=[sufs.outputs, 'connect/'];
sufs.bsc = [sufs.outputs,'/beta_series_corr/'];
sufs.dec_corr = [sufs.outputs,'dec_val_corr/'];

%% Create folders if they don't already exist
if ~exist(sufs.beh);mkdir(sufs.beh);end
if ~exist(sufs.brain);mkdir(sufs.brain);end
if ~exist(sufs.mask);mkdir(sufs.mask);end
if ~exist(sufs.retMap);mkdir(sufs.retMap);end
if ~exist(sufs.spm);mkdir(sufs.spm);end
if ~exist(sufs.eyemov);mkdir(sufs.eyemov);end
if ~exist(sufs.hc);mkdir(sufs.hc);end
if ~exist(sufs.outputs);mkdir(sufs.outputs);end
if ~exist(sufs.figures);mkdir(sufs.figures);end
if ~exist(sufs.ppi);mkdir(sufs.ppi);end
if ~exist(sufs.gppi);mkdir(sufs.gppi);end
if ~exist(sufs.connect);mkdir(sufs.connect);end
if ~exist(sufs.bsc);mkdir(sufs.bsc);end
if ~exist(sufs.day1);mkdir(sufs.day1);end
if ~exist(sufs.post);mkdir(sufs.post);end
if ~exist(sufs.dec_corr);mkdir(sufs.dec_corr);end


end
