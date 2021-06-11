function cfg=update_cfg_LSS_RSA(sub_code,sufs,cfg,labelname1,tag)

% Now with the names of the labels, we can extract the filenames and the
% run numbers of each label. The labels will be -1 and 1.
% Important: You have to make sure to get the label names correct and that
% they have been uniquely assigned, so please check them in regressor_names

% === Manual Creation ===
% Alternatively, you can also manually prepare the files field.
% For this, you have to load all images and labels you want to use
% separately, e.g. with spm_select. This is not part of this example, but
% if you do it later, you should end up with the following fields:
%   cfg.files.name: a 1xn cell array of file names
%   cfg.files.chunk: a 1xn vector of run numbers
%   cfg.files.label: a 1xn vector of labels (for decoding, you can choose
%       any two numbers as class labels)

if strcmpi(tag, 'XC') || strcmpi(tag, 'XC_sem') %If XC
    XC=1;
else
    XC=0;
end

% Load LSS info
load([sufs.spm, 'LSS_eye/betas/', sub_code, '_beta_info.mat'])
beta_names={};run_labels=[];c=1;beta_labels=[];
if size(trialinfo,1)>384
    temp=trialinfo(2:end,4);
    temp=cell2mat(temp);
    ind=find(temp>6);
    trialinfo(ind',:)=[];
end
for i=2:length(trialinfo)
    beta_names{c}=[sufs.spm, 'LSS_eye/betas/',trialinfo{i,8}];
    run_labels(c)=trialinfo{i,2};
    beta_labels(c)=(trialinfo{i,3});
    beta_labels_RSA{c}=trialinfo{i,6};
    c=c+1;
end



if XC==0
%     if numel(labelname1)>1 % If doing objects (i.e., 2 scenes per label)
%         
%         beta_labels(beta_labels==labelname1(1))=1001;
%         beta_labels(beta_labels==labelname1(2))=1001;
%         beta_labels(beta_labels==labelname2(1))=1002;
%         beta_labels(beta_labels==labelname2(2))=1002;
%         labelname1=1001;labelname2=1002;
%         
%     end
elseif XC
    
    test_label=labelname2;
    labelname2=labelname1(2);
    labelname1=labelname1(1);
    
end

% If doing XC, we need to select the test betas here
if XC
    testbeta_ind=beta_labels==test_label(1) | beta_labels == test_label(2);
    testbeta_names=beta_names(testbeta_ind);
    testbeta_labels=beta_labels(testbeta_ind);
    testrun_labels=run_labels(testbeta_ind);
end
% Select the betas for this comparison
beta_ind=beta_labels==labelname1(1);
for i=2:length(labelname1)
beta_ind=[beta_ind | beta_labels==labelname1(i)];
end
beta_names=beta_names(beta_ind);
beta_labels=beta_labels(beta_ind);
beta_labels=repmat(1:length(beta_labels)/4,1,4); %% This is here so that RSA script know that each beta is different
% beta_labels_RSA=beta_labels_RSA(beta_ind); 
run_labels=run_labels(beta_ind);

cfg.files.name=beta_names;

% Get run labels
cfg.files.chunk=run_labels';

% Get class labels
cfg.files.label=beta_labels';

%% Third, create your design for the decoding analysis
% === Manual Creation ===
% In a design, there are several matrices, one for training, one for test,
% and one for the labels that are used (there is also a set vector which we
% don't need right now). In each matrix, a column represents one decoding
% step (e.g. cross-validation run) while a row represents one sample (i.e.
% brain image). The decoding analysis will later iterate over the columns
% of this design matrix. For example, you might start off with training on
% the first 5 runs and leaving out the 6th run. Then the columns of the
% design matrix will look as follows (we also add the run numbers and file
% names to make it clearer):
% cfg.design.train cfg.design.test cfg.design.label cfg.files.chunk  cfg.files.name
%        1                0              -1               1         ..\beta_0001.img
%        1                0               1               1         ..\beta_0002.img
%        1                0              -1               2         ..\beta_0009.img
%        1                0               1               2         ..\beta_0010.img
%        1                0              -1               3         ..\beta_0017.img
%        1                0               1               3         ..\beta_0018.img
%        1                0              -1               4         ..\beta_0025.img
%        1                0               1               4         ..\beta_0026.img
%        1                0              -1               5         ..\beta_0033.img
%        1                0               1               5         ..\beta_0034.img
%        0                1              -1               6         ..\beta_0041.img
%        0                1               1               6         ..\beta_0042.img

nObs_test=size(beta_labels,2)/4;
test_ind=zeros(size(beta_labels,2),4);train_ind=test_ind;
for cRun=1:4
    test_ind(1+nObs_test*(cRun-1):nObs_test+nObs_test*(cRun-1),cRun)=1;
end
train_ind=double(~test_ind);

% for i=1:length(beta_labels)
%     if beta_labels(i)==labelname1
%         beta_labels(i)=-1;
%     elseif beta_labels(i)==labelname2
%         beta_labels(i)=1;
%     end
% end

if XC
    train_ind=[train_ind;repmat(0,size(train_ind,1),size(train_ind,2))];
     test_ind=[repmat(0,size(test_ind,1),size(test_ind,2));test_ind];
     beta_labels=[beta_labels,beta_labels];
     cfg.files.name=[beta_names,testbeta_names];
     cfg.files.chunk=[run_labels,testrun_labels];
     cfg.files.label=beta_labels;
end
cfg.design.train=train_ind;
cfg.design.test=test_ind;
cfg.design.label=repmat(beta_labels',1,4);
% cfg.design.label=repmat(beta_labels_RSA',1,4);
cfg.design.set=[1,1,1,1];

% You can then check it by visual inspection.
% Dependencies between training and test set will be checked
% automatically in the main function.

% if you want to see your design matrix, use
% display_design(cfg);
% plot_design(cfg)
% Fix some parameters
% cfg.design.unbalanced_data = 'ok';
% cfg.decoding.software = 'ensemble_balance';
% cfgd = decoding_defaults; % to use default values
% cfg.decoding.train.classification_kernel.model_parameters=[];
% cfg.decoding.test.classification_kernel.model_parameters=[];
% cfg.decoding.train.classification_kernel.model_parameters.software = 'libsvm';
% cfg.decoding.train.classification_kernel.model_parameters.n_iter = 100;
% cfg.decoding.train.classification_kernel.model_parameters.model_parameters = cfgd.decoding.train.classification_kernel.model_parameters;
% cfg.decoding.test.classification_kernel.model_parameters.model_parameters = cfgd.decoding.test.classification_kernel.model_parameters;
% cfg.results.output = {'accuracy_minus_chance'};
end