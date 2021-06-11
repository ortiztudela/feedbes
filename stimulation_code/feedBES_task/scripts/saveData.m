%% Project: MEMORY-DRIVEN PREDICTIONS. Hippocampus localizer output generator.
%Outpus prt files for brainvoyager
% ---------------------------------------
function saveData(taskName,cSub,cRun,fileFormat)

% Get path to data
root = ['../results/' taskName];

% Load data
load([root '_' num2str(cSub) '_params.mat'])
if ~exist('r','var')
    load([root '_' num2str(cSub) '_run'  num2str(cRun) '_data.mat'])
end

% Get conditions info
condLabels=p.condLabels;
nConditions=length(condLabels);
colorCond={'128 128 128';'255 0 0';'0 255 0';'0 0 255'}; % Red, green and blue (add more colors for more conditions)

% ChB  info
chBLabels=p.chBLabels;
nChB=p.nChB/2;
colorChB={'255 255 0';'255 0 255';'0 255 255';'100 100 100'};

% Turn seconds into milliseconds
blockOnsetCorr=r.blockOnset*1000;
blockOffsetCorr=r.blockOffset*1000;
offPOnsetCorr=r.offPOnset*1000;
offPOffsetCorr=r.offPOffset*1000;

%% Get conditions info from p
% Fixation onsets
fixationTable=[];dataTable =[];
fixationTable(:,1:2)=[offPOnsetCorr(:),offPOffsetCorr(:)];
fixationTable=[0,12000;fixationTable;offPOffsetCorr(end)+1,r.runOffset*1000];
nRepetitions(1)=length(fixationTable);

% Conditions onsets
for cCond=1:nConditions-1
    for i=1:length(p.expDes)
        dataTable(:,1,cCond)=blockOnsetCorr(p.expDes(:,cRun)==cCond);
        dataTable(:,2,cCond)=blockOffsetCorr(p.expDes(:,cRun)==cCond);
        nRepetitions(cCond+1)=sum(p.expDes(:,cRun)==cCond);
    end
end

% Checkerboard onsets
chBTable(:,1,1)=blockOnsetCorr(p.expDes(:,cRun)==10);
chBTable(:,2,1)=blockOffsetCorr(p.expDes(:,cRun)==10);
chBTable(:,1,2)=blockOnsetCorr(p.expDes(:,cRun)==11);
chBTable(:,2,2)=blockOffsetCorr(p.expDes(:,cRun)==11);
chBTable(:,1,3)=blockOnsetCorr(p.expDes(:,cRun)==12);
chBTable(:,2,3)=blockOffsetCorr(p.expDes(:,cRun)==12);
chBTable(:,1,4)=blockOnsetCorr(p.expDes(:,cRun)==13);
chBTable(:,2,4)=blockOffsetCorr(p.expDes(:,cRun)==13);

%% Start output file with header info
fid = fopen([root '_' num2str(cSub) '_run' num2str(cRun) '.' fileFormat],'w');
fprintf(fid, 'FileVersion:\t2\n\n');
fprintf(fid, 'ResolutionOfTime:\tMilliseconds\n\nExperiment:\t%s\n\nBackgroundColor:\t0\t0\t0\n',taskName);
fprintf(fid, 'TextColor:\t255\t255\t255\nTimeCourseColor:\t255\t255\t255\nTimeCourseThick:\t3\nReferenceFuncColor:\t0\t0\t80\nReferenceFuncThick:\t3\n');
fprintf(fid, '\nNrOfConditions:\t%d\n', nConditions +nChB);

% Print conditions info
c=1; % Counter for checkerB
for cCond=1:nConditions+length(chBLabels)
    if cCond<=nConditions
        fprintf(fid, '\n%s\n', condLabels{cCond});
        fprintf(fid, '%d\n', nRepetitions(cCond));
        if cCond==1
            for i=1:length(fixationTable)
                fprintf(fid, '%d\t%d\n',round(fixationTable(i,:)));
            end
        else
            for i=1:length(dataTable)
                fprintf(fid, '%d\t%d\n',round(dataTable(i,:,cCond-1)));
            end
        end
        fprintf(fid, 'Color: %s\n', colorCond{cCond});
    elseif cCond>nConditions % Print chB info
        fprintf(fid, '\n%s\n', chBLabels{c});
        fprintf(fid, '%d\n', nChB);
        for i=1:size(chBTable,1)
            fprintf(fid, '%d\t%d\n',round(chBTable(i,:,c)));
        end
        fprintf(fid, 'Color: %s\n', colorChB{c});
        c=c+1;
    end
end
fclose(fid);

%% Save trial info in convenient format
% Get run labels
obj_labels=r.objLabels';
scn_labels=r.scnLabels';
fix_labels=r.fixLabels';

% Remove intermediate mapping labels
for i=1:p.nChB
    where=min(find(strcmpi(obj_labels,p.chBLabels{i})));
    obj_labels(where)=[];
    scn_labels(where)=[];
    fix_labels(where)=[];
end

% Create trial info run matrix
run_mat=[scn_labels,obj_labels, fix_labels];

% Save it
save([root '_' num2str(cSub) '_trialInfo_' num2str(cRun) '.mat'], ...
    'scn_labels','obj_labels','fix_labels','run_mat')

%% Print info to a text file for visual inspection
% Print trial labels to txt file (cue scenes)
fid = fopen([root '_' num2str(cSub) '_run' num2str(cRun) '_mat.txt'],'w');
for i=1:length(run_mat)
    fprintf(fid, '\t%s\t%s\t%s\n\n', run_mat{i,1},run_mat{i,2},run_mat{i,3});
end
fclose(fid);

end