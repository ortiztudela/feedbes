%% FeedBES. FeedBack signals from Episodic and Semantic memories"
% author: "Javier Ortiz-Tudela" (Goethe Uni)
% ---
% *Contact: ortiztudela@psych.uni-frankfurt.de*
%
% *date: Jun 03 2020*

% Univariate contrast from SPM.mat
which_sub=[1:5,7:9];

% Which classification?
cAnal=3;
if cAnal==2; class_label='scn';elseif cAnal==3; class_label='obj';end

%% Add necessary paths
% Main folder.
if strcmpi(getenv('USERNAME'),'javier')
    samba_folder= '/home/javier/pepe/';
    spm_folder='/home/javier/pepe/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'), 'ortiz')
        samba_folder= '/home/javier/pepe/';
    spm_folder='/home/ortiz/DATA/2_Analysis_Folder/_common_software/spm12';
    main_folder='/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
else % Replace below with the paths for your computer
    samba_folder= 'smb://ntsamba1.server.uni-frankfurt.de/entwicklungspsychologie';
    spm_fodler='/Users/Nina/spm12'; %add path to my spm
    main_folder= [samba_folder, '/2_Student_Analysis/PIVOTAL/FeedBES'];
end

%% start looping over subjects
for cSub = which_sub
    ['Starting sub ', num2str(cSub)]
    clear matlabbatch
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.con.spmmat = {[sufs.connect, 'GLM_', class_label, '_collapsed_GMmask/SPM.mat']}; % Output folder
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'dec_episodic';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [zeros(1,21),1,0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
end
