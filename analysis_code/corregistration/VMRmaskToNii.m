function [mask_mat]=VMRmaskToNii(cSub, sufs, sub_code, voi_name)
% This script registers a VMR mask into a ref_file.
% Takes in a VMR file with only the masked voxels and the whole brain
% VMR from which the mask was drawn. Both files are converted into Nifti and
% registered in two-steps.

% If called with output variable, it will ouput a 3D matrix for the new
% mask.

%% Add paths
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be
addpath(genpath([sufs.main, '/analysis_scripts/NeuroElf_v11_7251/']))
%% Convert mask VMR file into Nifti

% Load VMR file with only the ROI voxels
'Loading VMR mask...'
mask=xff([sufs.retMap,...
    sub_code,'_',voi_name,'_mask.vmr']);

% Get a copy of the data
mask_data=mask.VMRData;
mask_data=shiftdim(mask_data,2);
mask_data=flipdim(mask_data,1);
mask_data=flipdim(mask_data,2);
mask_data=flipdim(mask_data,3);

% Locate voxels and turn them into 1s
loc=find(mask_data>0);
mask_data(loc)=1;

% Load anatomical to use as an envelope
niiF=xff([sufs.BIDS, 'ses-02/anat/',...
    sub_code,'_ses-02_acq-orig_T1w.nii.gz']);

% Put the data back in and save it
niiF.VoxelData=mask_data;
niiF.SaveAs([sufs.mask,sub_code, '_',voi_name,'_mask_native.nii.gz']);

%% Obtain transformation from anat ses02 to func
% Build names for FSL
input_image=[sufs.BIDS, 'ses-02/anat/',sub_code,'_ses-02_acq-orig_T1w.nii.gz'];

if cSub==6
    ref_image=[sufs.brain, 'ses-02/func/', sub_code,'_ses-02_task-feedBES_run-3_space-MNI152NLin2009cAsym_boldref.nii.gz'];
    out_image= [sufs.mask,sub_code,'_ses-02_to_averageMNI152.nii'];
    trf_matrix= [sufs.mask,sub_code,'_ses-02_to_averageMNI152_trf.mat'];
else
    ref_image=[sufs.brain, 'ses-02/func/', sub_code,'_ses-02_task-feedBES_run-3_space-T1w_boldref.nii.gz'];
    out_image= [sufs.mask,sub_code,'_ses-02_to_anat.nii'];
    trf_matrix= [sufs.mask,sub_code,'_ses-02_to_anat_trf.mat'];
end
opt_params= '-bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear';

% Obtain registration matrix to functional image if it doesn't already
% exist. It is important to obtain this for functional image and not the
% anatomical so we don't have problems with the FOV later
if ~exist(trf_matrix, 'file')
    cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -out %s -omat %s %s', ...
        input_image, ref_image, out_image, trf_matrix, opt_params);
    'Obtaining registration matrix...'
    system(cmd);
    
else
    'Trf matrix already exists... Will now register the mask to ref file'
end

%% Transfor the mask in Nifti format with the transformation matrix obtained above.

% Build names for FSL
input_mask= [sufs.mask,sub_code, '_',voi_name,'_mask_native.nii'];
out_mask= [sufs.mask,sub_code,'_', voi_name,'_correg.nii.gz'];
if cSub==6
    ref_image=[sufs.brain, 'ses-02/func/', sub_code,'_ses-02_task-feedBES_run-3_space-MNI152NLin2009cAsym_boldref.nii.gz'];
else
    ref_image=[sufs.brain, 'ses-02/func/', sub_code,'_ses-02_task-feedBES_run-3_space-T1w_boldref.nii.gz'];
end

% Here we use the ref image only for voxel size and FOV.
if ~exist(out_mask, 'file')
    cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -applyxfm -init %s -out %s', ...
        input_mask, ref_image, trf_matrix, out_mask);
    ['Transforming VOI '];
    system(cmd);
    
    cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', out_mask, out_mask);
    ['Binarizing mask...'];
    system(cmd);
else
    'Mask already exists... Will load it'
end

% Output new mask as a matrix and save it for later use
new_mask=xff(out_mask);
mask_mat=new_mask.VoxelData;

end
