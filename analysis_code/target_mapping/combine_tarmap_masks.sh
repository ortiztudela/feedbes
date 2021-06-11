# This script combines retmap and tarmap masks
# This should be run after "contrast_spm.m" script that runs the GLM
# creates the contrast and removes fovea voxels from periphery image and
# periphery voxels from the fovea image.

main_dir=$1
dir=$main_dir/spm_analyses/
mask_dir=$main_dir/masks
threshold=0
cSub=0$2
roi=$3

echo "sub-$cSub"
# Threshold tarmap
fslmaths $dir/sub-$cSub""/tarmap_spm/periph_Ts.nii -thr $threshold \
-bin $dir/../masks/sub-$cSub""/periph_mask.nii.gz
fslmaths $dir/sub-$cSub""/tarmap_spm/fovea_Ts.nii -thr $threshold \
-bin $dir/../masks/sub-$cSub""/fov_mask.nii.gz

# Change dir
#cd ../masks/sub-$cSub""/

# V1
# Among all the target>surr voxels, select only v1
fslmaths $mask_dir/sub-$cSub""/periph_mask.nii.gz -mul $mask_dir/sub-$cSub""/sub-$cSub""_$roi""_correg.nii.gz $mask_dir/sub-$cSub""/sub-$cSub""_$roi""_periph_correg.nii.gz
fslmaths $mask_dir/sub-$cSub""/fov_mask.nii.gz -mul $mask_dir/sub-$cSub""/sub-$cSub""_$roi""_correg.nii.gz $mask_dir/sub-$cSub""/sub-$cSub""_$roi""_fov_correg.nii.gz

