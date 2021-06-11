function [DM_conv,conv_labels,onsets]=feedbes_desMat_runs(sufs, cSub, cRun, nVols, TR)
% Runs a glm to get the t values for periphery vs surrounding across all runs.

% Load parameters
load([sufs.beh, '/feedBES_', num2str(cSub), '_params.mat'])
load([sufs.beh, '/feedBES_', num2str(cSub), '_run', num2str(cRun) '_data.mat'])
DM_unconv=[];onsets=[];DM_conv=[];

if ~isempty(nVols) % I include this to be able to use this function in SPM as well when no nVols are included
    netools = neuroelf; hr_func_ms = netools.hrf('twogamma', 1/1000);

    % Pre-allocate
    nPreds=p.pred.nTrials;
    acquisitDur=nVols*TR;
    DM_unconv=zeros(acquisitDur, nPreds);

    %% Build design matrix

    % Convert timing in milliseconds
    r.trialOnset=floor(r.trialOnset*1000);r.trialOffset=floor(r.trialOffset*1000);
    r.trialOnset=r.trialOnset-4800;r.trialOffset=r.trialOffset-4800;r.trialOnset(1)=1;
    r.runOffset=floor(r.runOffset*1000);r.runOffset=r.runOffset-4800;
    for i=1:length(r.trialOnset)
        DM_unconv(r.trialOnset(i):r.trialOffset(i),i)=1;
    end

    % Convolve with HRF
    % ['........ convolving DM with HRF' ]
    temp=convn(DM_unconv,hr_func_ms); %convolve with hrf
    temp=temp(1:acquisitDur, :); %cut back to original size
    DM_conv_ms=temp;
    DM_conv=DM_conv_ms(1:TR:acquisitDur, :);

    % Add constant
    DM_conv(:,end+1)=ones;

    % Plot DMs
    subplot(1,3,1), imagesc(DM_unconv)
    subplot(1,3,2), imagesc(DM_conv_ms)
    subplot(1,3,3), imagesc(DM_conv)
    sgtitle(['Design matrix. Run ', num2str(cRun)])

end

%% Turn scene names into numbers

% Pre-allocate
conv_labels = zeros(p.pred.nTrials,1);


% Counterbalance scenes labels across subjects
if cSub==299
    tmp = r.pred.scn_labels(:,cRun);
    
    conv_labels(strcmp(tmp, 'livingroom'))=1;
    conv_labels(strcmp(tmp, 'electronics'))=2;
    conv_labels(strcmp(tmp, 'bathroom'))=3;
    conv_labels(strcmp(tmp, 'bathstore'))=4;
    conv_labels(strcmp(tmp, 'kitchen'))=5;
    conv_labels(strcmp(tmp, 'kitchenstore'))=6;
    conv_labels(strcmp(tmp, 'bedroom'))=7;
    conv_labels(strcmp(tmp, 'bedstore'))=8;
    conv_labels(strcmp(tmp, 'livingroom2'))=17;
    conv_labels(strcmp(tmp, 'electronics2'))=18;
    conv_labels(strcmp(tmp, 'bathroom2'))=11;
    conv_labels(strcmp(tmp, 'bathstore2'))=12;
    conv_labels(strcmp(tmp, 'kitchen2'))=13;
    conv_labels(strcmp(tmp, 'kitchenstore2'))=14;
    conv_labels(strcmp(tmp, 'bedroom2'))=15;
    conv_labels(strcmp(tmp, 'bedstore2'))=16;
elseif mod(cSub,2)==1
    
    tmp = p.pred.scn_labels(:,cRun);
    conv_labels(strcmp(tmp, 'livingroom'))=1;
    conv_labels(strcmp(tmp, 'electronics'))=11;
    conv_labels(strcmp(tmp, 'bathroom'))=3;
    conv_labels(strcmp(tmp, 'bathstore'))=13;
    conv_labels(strcmp(tmp, 'kitchen'))=15;
    conv_labels(strcmp(tmp, 'kitchenstore'))=5;
    conv_labels(strcmp(tmp, 'bedroom'))=17;
    conv_labels(strcmp(tmp, 'bedstore'))=7;
    conv_labels(strcmp(tmp, 'livingroom2'))=2;
    conv_labels(strcmp(tmp, 'electronics2'))=12;
    conv_labels(strcmp(tmp, 'bathroom2'))=4;
    conv_labels(strcmp(tmp, 'bathstore2'))=14;
    conv_labels(strcmp(tmp, 'kitchen2'))=16;
    conv_labels(strcmp(tmp, 'kitchenstore2'))=6;
    conv_labels(strcmp(tmp, 'bedroom2'))=18;
    conv_labels(strcmp(tmp, 'bedstore2'))=8;
    
elseif mod(cSub,2)==0
    tmp = p.pred.scn_labels(:,cRun);
    conv_labels(strcmp(tmp, 'livingroom'))=11;
    conv_labels(strcmp(tmp, 'electronics'))=1;
    conv_labels(strcmp(tmp, 'bathroom'))=13;
    conv_labels(strcmp(tmp, 'bathstore'))=3;
    conv_labels(strcmp(tmp, 'kitchen'))=5;
    conv_labels(strcmp(tmp, 'kitchenstore'))=15;
    conv_labels(strcmp(tmp, 'bedroom'))=7;
    conv_labels(strcmp(tmp, 'bedstore'))=17;
    conv_labels(strcmp(tmp, 'livingroom2'))=12;
    conv_labels(strcmp(tmp, 'electronics2'))=2;
    conv_labels(strcmp(tmp, 'bathroom2'))=14;
    conv_labels(strcmp(tmp, 'bathstore2'))=4;
    conv_labels(strcmp(tmp, 'kitchen2'))=6;
    conv_labels(strcmp(tmp, 'kitchenstore2'))=16;
    conv_labels(strcmp(tmp, 'bedroom2'))=8;
    conv_labels(strcmp(tmp, 'bedstore2'))=18;
end

%% Ouput onsets too
onsets=r.trialOnset;

end