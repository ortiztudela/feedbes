function cfg=update_cfg_LSS(sub_code,sufs,cfg,labelname1,labelname2,tag, eye_tag)
% 28/09/2020. JOT clean this up to leave only the essential lines of code.
% This script is called from either feedbes_class

if strcmpi(tag, 'XC') || strcmpi(tag, 'XC_sem') %If XC
    XC=1;
else
    XC=0;
end

%% Load LSS info
beta_folder=[sufs.spm, 'LSS_', eye_tag, '/betas/'];
load([beta_folder, sub_code, '_beta_info.mat'])
beta_names={};run_labels=[];c=1;beta_labels=[];
for i=2:length(trialinfo)
    beta_names{c}=[beta_folder,trialinfo{i,8}];
    run_labels(c)=trialinfo{i,2};
    beta_labels(c)=(trialinfo{i,3});
    c=c+1;
end

% A few tweaks for different classifications
if XC==0
    if numel(labelname1)>1 % If doing objects (i.e., 2 scenes per label)
        
        beta_labels(beta_labels==labelname1(1))=1001;
        beta_labels(beta_labels==labelname1(2))=1001;
        beta_labels(beta_labels==labelname2(1))=1002;
        beta_labels(beta_labels==labelname2(2))=1002;
        labelname1=1001;labelname2=1002;
        
    end
elseif XC
    
    test_label=labelname2;
    labelname2=labelname1(2);
    labelname1=labelname1(1);
    
end

% If doing XC, we need to select the test betas here
if XC
    testbeta_ind=beta_labels==test_label(1) | beta_labels == test_label(2);
    testbeta_names=beta_names(testbeta_ind);
    testbeta_labels=beta_labels(testbeta_ind); % These are the old labels and therefore not used
    testrun_labels=run_labels(testbeta_ind);
end
%% Select the betas for this comparison
% We need filenames, run labels and beta labels
beta_ind=beta_labels==labelname1 | beta_labels == labelname2;
beta_names=beta_names(beta_ind);
beta_labels=beta_labels(beta_ind);
run_labels=run_labels(beta_ind);

%% Pass beta info to cfg.
cfg.files.name=beta_names;
cfg.files.chunk=run_labels;
cfg.files.label=beta_labels;

%% Manually create your design for the decoding analysis
% How many observations per category?
nObs_categ=size(beta_labels,2)/2;
ntest_label=nObs_categ/4; %nObservation per label per fold

% How many test observations?
nObs_test=size(beta_labels,2)/4;

% How many train observations?
nObs_train=size(beta_labels,2);

% Initialize empty designs (Observation X Folds)
test_ind=zeros(size(beta_labels,2),4);train_ind=test_ind;

% Loop through folds to fill in the test matrix
for cRun=1:4
    test_ind(1+nObs_test*(cRun-1):nObs_test+nObs_test*(cRun-1),cRun)=1;
end

% The train matrix is the opposite to the test one
train_ind=double(~test_ind);

if XC
    train_ind=[train_ind;repmat(0,size(train_ind,1),size(train_ind,2))];
    test_ind=[repmat(0,size(test_ind,1),size(test_ind,2));test_ind];
    beta_labels=[beta_labels,beta_labels];
    cfg.files.name=[beta_names,testbeta_names];
    cfg.files.chunk=[run_labels,testrun_labels];
    cfg.files.label=beta_labels;
end

%% Pass design info to cfg.
cfg.design.train=train_ind;
cfg.design.test=test_ind;
cfg.design.label=repmat(beta_labels',1,4);
cfg.design.set=[1,1,1,1];

% if you want to see your design matrix, use
% display_design(cfg);
if ~exist([sufs.figures, tag, '_Xval_scheme.png'])
    plot_design(cfg)
    print([sufs.figures, tag, '_Xval_scheme.png'],'-dpng')
end
close all
end