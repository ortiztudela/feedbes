%% FeedBES PPI Analysis - Script 03 - Move and rename the template files
%
% Author: Isabelle Ehrlich
% Lifespan Cognitive and Brain Development (LISCO) Lab
% Goethe University Frankfurt am Main
%
%% Description
%
% This is a script that checks whether there is a compressed nifti file,
% removes the extracted one, copies the template in the according "run" folder and renames it to "sub-%s_design_file_run%s.fsf".
% You might add the path to the functions!
% 
%% GO!

% Get the directory to the main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'),'ehrlich')
    main_folder= '/home/ehrlich/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
    %main_folder= '/mnt/md0/2_Analysis_Folder/PIVOTAL/FeedBES';
    addpath '/home/ehrlich/pepe/2_Analysis_Folder/PIVOTAL/FeedBES/analysis_scripts/clean/_functions'
elseif strcmpi(getenv('USER'),'ortiz')
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end

% You might add the path to the functions
%addpath('/mnt/md0/2_Analysis_Folder/PIVOTAL/FeedBES/analysis_scripts/clean/_functions')

% Specify which subjects you want to run
which_sub = [1:30];
which_runs = [1:4];

% Loop over all the subjects and runs
for cSub = which_sub
    
    % Get folder structure
    [sufs, sub_code]=feedBES_getdir(main_folder, cSub);
    ['Starting ', sub_code]
    
    % First loop to create directories and copy files (sequential)
    for cRun=which_runs
        if ~exist([sufs.ppi, 'run', num2str(cRun)])
            mkdir([sufs.ppi, 'run', num2str(cRun)])
        end
        
        % Get session number and check if uncompressed files are present
        if cRun<3; ses_nb='01';else ses_nb='02';end
        
        if exist([sufs.brain, 'ses-', ses_nb,'/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-MNI152NLin2009cAsym_desc-sm_bold.nii.gz'])
            system(['rm ' sufs.brain, 'ses-', ses_nb,'/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-MNI152NLin2009cAsym_desc-sm_bold.nii']);
        end
        
        % Copy design file
        sourceFile = [sufs.main, '/analysis_scripts/clean/PPI/FSL/PPI_EVC_allregs/01_Run_local/template_', sub_code, '_run', num2str(cRun), '.fsf'];
        destFile = [sufs.outputs,'PPI_results/run', num2str(cRun), '/', sub_code, '_design-file.fsf'];
        copyfile(sourceFile, destFile);

    end
    
end
