%% Eye movement info 
% Creates csv with eye movement information for SPM from the outputs 
% obtained with the GUI that takes in the epi sequences.

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
nRuns=4;
which_subs=[19];

%% Loop through subjects
c=1;plot_oc=1;plot_mov=0;d=1;
for cSub=which_subs
    cSub
    % Get paths
    [sufs, sub_code]=feedBES_getdir(main_folder,cSub);
    
    % Loop through runs
    for cRun=1:nRuns
        
        % Load results
        load([sufs.eyemov, 'run', num2str(cRun), '/eye_analyse.mat'])
        data=param.results.last_vec;
        
        % Get data
        out_l=data.l;
        out_r=data.r;
        out=[out_l, out_r];
        csvwrite([sufs.eyemov,'run', num2str(cRun),  '/eyes_mov_data.csv'], out)
    end
end