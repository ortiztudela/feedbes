% Browse through folders looking for duplicates of niftis (.nii and
% .nii.gz) and removes the non-compressed version.

function cleanup_niftis(which_sub) %I changed nifits to niftis
%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'),'ortiz')
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USER'),'ehrlich')
    main_folder= '/home/ehrlich/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end

for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    ['Starting ', sub_code]
    
    % Look at the masks folder
    nii_files=dir([sufs.mask, '*nii']);
    for cFile=1:length(nii_files)
        compressed=[nii_files(cFile).folder, '/', nii_files(cFile).name, '.gz'];
        uncompressed=[nii_files(cFile).folder, '/', nii_files(cFile).name];
        if exist(compressed, 'file')
            system(['rm ', uncompressed]);
        else
            gzip(uncompressed);
            system(['rm ', uncompressed]);
        end
    end
    
    % Look at the preproc folder
    nii_files=dir([sufs.brain, '*/*/*nii']);
    for cFile=1:length(nii_files)
        compressed=[nii_files(cFile).folder, '/', nii_files(cFile).name, '.gz'];
        uncompressed=[nii_files(cFile).folder, '/', nii_files(cFile).name];
        if exist(compressed, 'file')
            system(['rm ', uncompressed]);
        else
            'Compressing nii...'
            gzip(uncompressed);
            system(['rm ', uncompressed]);
        end
    end

end