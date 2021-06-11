% Univariate contrast from SPM.mat
% Author: Ortiz-Tudela (Goethe Uni)

function contrast_tarmap_SPM(which_sub)

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end

%% start looping over subjects
for cSub = which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.stats.con.spmmat = {[sufs.spm, 'tarmap_spm/SPM.mat']};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'fovT>fovS';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'periphT>periphS';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 1 -1];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    
    %% Periph and Fov
    % Now I will use FSL to separate periphery from foveal voxels
    ['Creating independent t maps ']
    tarmap_folder=[sufs.spm, 'tarmap_spm/'];
    cmd = sprintf('/usr/local/fsl/bin/fslmaths %sspmT_0002.nii -sub %sspmT_0001.nii %speriph_Ts.nii.gz',...
        tarmap_folder,tarmap_folder,tarmap_folder);
    system(cmd);
    cmd = sprintf('/usr/local/fsl/bin/fslmaths %sspmT_0001.nii -sub %sspmT_0002.nii %sfovea_Ts.nii.gz',...
        tarmap_folder,tarmap_folder,tarmap_folder);system(cmd);
end