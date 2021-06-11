function feedbes_ashs_subfields_correg(cSub, sufs, sub_code)
% set FSL environment
setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be


% Get segmantation labels from atlases/ATLAS_USED/snap/snap_lables.txt
available_labels={
    'ERC', 10;
    'CA1', 1;
    'SUB', 8;
    'DG', 3;
    'CA2', 2;
    'CA3', 4
    };

for cSubF=1:length(available_labels)
    
    % State
    ['Starting ', available_labels{cSubF}]
    % Select the current label
    roi_name=available_labels{cSubF,1};
    segm_code=available_labels{strcmpi(roi_name, available_labels(:,1)),2};
    
    % Build final filename
    combined_im=[sufs.hc, 'ASHS_segmentations/final/',...
        sub_code, '_', roi_name, '.nii.gz'];
    
    % Loop through hemispheres
    out_image={};
    if ~exist(combined_im, 'file')
        hem_tag={'left';'right'};
        for cHem=1:2
            
            ASHS_segmentation = [sufs.hc, 'ASHS_segmentations/final/',...
                sub_code, '_', hem_tag{cHem}, '_lfseg_corr_usegray.nii.gz'];
            
            % Build image name
            out_image{cHem}= [sufs.hc, 'ASHS_segmentations/final/',...
                sub_code, '_',  hem_tag{cHem}, '_', roi_name, '.nii.gz'];
            
            % Print commands and run them
            ['Extracting masks from ASHS outputs hemisph ', hem_tag{cHem}]
            cmd = sprintf('/usr/local/fsl/bin/fslmaths %s -thr %d -uthr %d %s', ...
                ASHS_segmentation, segm_code, segm_code, out_image{cHem});
            system(cmd);
        end
        
        % Combine the segmentations
        cmd = sprintf('/usr/local/fsl/bin/fslmaths %s -add %s %s', ...
            out_image{1}, out_image{2}, combined_im);
        system(cmd);
        
        % Binarize the mask
        cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', combined_im, combined_im);
        system(cmd);
    end
    
    %% If it doesn't exist, obtain a transformation matrix from highres to T1w
    % Build names for FSL
    if cSub~=6
        input_image=[sufs.hc, sub_code,'_ses-01_acq-hcHighres_T1w.nii.gz'];
        ref_image=[sufs.brain, 'anat/', sub_code,'_desc-preproc_T1w.nii.gz'];
        out_image= [sufs.mask,sub_code,'_highres_to_anat.nii'];
        trf_matrix= [sufs.mask,sub_code,'_highres_to_anat_trf.mat'];
    else
        input_image=[sufs.hc, sub_code,'_ses-01_acq-hcHighres_T1w.nii.gz'];
        ref_image=[sufs.brain, 'anat/', sub_code,'_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz'];
        out_image= [sufs.mask, sub_code,'_highres_to_averageMNI152.nii'];
        trf_matrix= [sufs.mask, sub_code,'_highres_to_averageMNI152_trf.mat'];
    end
    if cSub~=6
        opt_params= '-bins 256 -cost corratio -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 12  -interp trilinear';
    else
        opt_params= '-bins 256 -cost mutualinfo -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 6  -interp trilinear';
    end
%     opt_params= '-bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear';
    
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
    
    %% If it doesn't exist, obtain a second transformation matrix from func to T1w
    % Build names for FSL
    if cSub~=6
        input_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-1_space-T1w_boldref.nii.gz'];
        ref_image=[sufs.brain, 'anat/', sub_code,'_desc-preproc_T1w.nii.gz'];
        out_image= [sufs.mask,sub_code,'_func_to_anat.nii'];
        trf_matrix= [sufs.mask,sub_code,'_func_to_anat_trf.mat'];
    else
        input_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-1_space-MNI152NLin2009cAsym_boldref.nii.gz'];
        ref_image=[sufs.brain, 'anat/', sub_code,'_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz'];
        out_image= [sufs.mask,sub_code,'_func_to_averageMNI152.nii'];
        trf_matrix= [sufs.mask,sub_code,'_func_to_averageMNI152_trf.mat'];
    end
    if cSub~=6
        opt_params= '-bins 256 -cost corratio -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 12  -interp trilinear';
    else
        opt_params= '-bins 256 -cost mutualinfo -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 12  -interp trilinear';
        
    end
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
    
    %% Now invert the func to anat matrix
    trf_matrix_inv= [trf_matrix(1:end-4), '_inv.mat'];
    cmd = sprintf('/usr/local/fsl/bin/convert_xfm -omat %s -inverse %s', ...
        trf_matrix_inv, trf_matrix);
    'Inverting matrix...'
    system(cmd);
    
    %% Concatenate matrices
    concat_matrix=[sufs.mask,sub_code,'_final_trf.mat'];
    if cSub~=6
        trf_matrix= [sufs.mask,sub_code,'_highres_to_anat_trf.mat'];
    else
        trf_matrix= [sufs.mask,sub_code,'_highres_to_averageMNI152_trf.mat'];
    end
    cmd = sprintf('/usr/local/fsl/bin/convert_xfm -omat %s -concat %s %s', ...
        concat_matrix, trf_matrix_inv, trf_matrix);
    'Concatenating matrices...'
    system(cmd);
    
    
    %% Now apply the combined transformation matrix to the mask
    
    % Build names for FSL
    input_image= combined_im;
    coreg_image= [sufs.mask, sub_code,'_', roi_name, '_correg.nii.gz'];
    if cSub~=6
        ref_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-1_space-T1w_boldref.nii.gz'];
    else
        ref_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-001_space-MNI152NLin2009cAsym_boldref.nii.gz'];
    end
    % Print commands and run them
    cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -applyxfm -init %s -out %s', ...
        input_image, ref_image, concat_matrix, coreg_image );
    ['Transforming subfield mask ']
    system(cmd);
    
    % Binarize the mask
    cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', coreg_image, coreg_image);
    system(cmd);
end

%% Build the HC mask
% Now that all the subfields masks have been extracted we will combine them
% into a single HC mask and corregister that one as well.
out_image={};
for cSubF=1:length(available_labels)
    
    % Build image name
    out_image{cSubF}= [sufs.hc, ...
        'ASHS_segmentations/final/', sub_code, '_', available_labels{cSubF}, '.nii.gz'];
    
    if cSubF==1
        cmd = sprintf('/usr/local/fsl/bin/fslmaths %s', ...
            out_image{cSubF});
    else
        cmd = sprintf('%s -add %s', ...
            cmd, out_image{cSubF});
    end
    
    % Here I'll build two HC masks for left and right hemispheres
    out_left_image{cSubF}= [sufs.hc, ...
        'ASHS_segmentations/final/', sub_code, '_left_', available_labels{cSubF}, '.nii.gz'];
    out_right_image{cSubF}= [sufs.hc, ...
        'ASHS_segmentations/final/', sub_code, '_right_', available_labels{cSubF}, '.nii.gz'];
     if cSubF==1
        cmd_left = sprintf('/usr/local/fsl/bin/fslmaths %s', ...
            out_left_image{cSubF});
        cmd_right = sprintf('/usr/local/fsl/bin/fslmaths %s', ...
            out_right_image{cSubF});
    else
        cmd_left = sprintf('%s -add %s', ...
            cmd_left, out_left_image{cSubF});
         cmd_right = sprintf('%s -add %s', ...
            cmd_right, out_right_image{cSubF});
     end
    
    
end
cmd = sprintf('%s %s',cmd, ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc.nii.gz']);system(cmd);
cmd_left = sprintf('%s %s',cmd_left, ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_left.nii.gz']);system(cmd_left);
cmd_right = sprintf('%s %s',cmd_right, ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_right.nii.gz']);system(cmd_right);

% Binarize the mask
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc.nii.gz'], ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc.nii.gz']);
system(cmd);
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_left.nii.gz'], ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_left.nii.gz']);
system(cmd);
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s', ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_right.nii.gz'], ...
    [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_right.nii.gz']);
system(cmd);

% Apply trf matrix if it exists
concat_matrix=[sufs.mask, sub_code,'_final_trf.mat'];
input_image= [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc.nii.gz'];
coreg_image= [sufs.mask, sub_code, '_hc_correg.nii.gz'];
if cSub~=6
    ref_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-1_space-T1w_boldref.nii.gz'];
else
    ref_image=[sufs.brain, 'ses-01/func/', sub_code,'_ses-01_task-feedBES_run-001_space-MNI152NLin2009cAsym_boldref.nii.gz'];
end
% Print commands and run them
cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -applyxfm -init %s -out %s', ...
    input_image, ref_image, concat_matrix, coreg_image );
['Transforming HC mask ']
system(cmd);
% Binarize the mask
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s',coreg_image, coreg_image);system(cmd);


% Now both hemispheres
input_image= [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_left.nii.gz'];
coreg_image= [sufs.mask, sub_code, '_hc_left_correg.nii.gz'];
cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -applyxfm -init %s -out %s', ...
    input_image, ref_image, concat_matrix, coreg_image );
['Transforming left HC mask ']
system(cmd);

% Binarize the mask
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s',coreg_image, coreg_image);system(cmd);

input_image= [sufs.hc, 'ASHS_segmentations/final/', sub_code, '_hc_right.nii.gz'];
coreg_image= [sufs.mask, sub_code, '_hc_right_correg.nii.gz'];
cmd = sprintf('/usr/local/fsl/bin/flirt -in %s -ref %s -applyxfm -init %s -out %s', ...
    input_image, ref_image, concat_matrix, coreg_image );
['Transforming right HC mask ']
system(cmd);

% Binarize the mask
cmd = sprintf('fslmaths %s -thr 0.2 -bin %s',coreg_image, coreg_image);system(cmd);

end
