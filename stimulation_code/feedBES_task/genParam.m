%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela
% ortiztudela@psych.uni-frankfurt.com
% LISCO Lab - Goethe Universit�t
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Additional info %%%
% This task aims at exploring the feedback signals to early visual cortex eithe
% from episodic and semantic memory traces. In this case, episodic and semantic 
% are equivalent to semantically congruent and incongruent. Participants
% are first expose to a learning phase and then, retrieval is performed
% inside the scanner.
%%%%%%%%%%%%%%%%%%%%%%%

%% Clean everything and define task name
clear
p.taskName= 'feedBES';

%% Define whether test or experimental session and whether plotting the design is ok.
% ----------------------------------------------------------
% Plot design matrix
pD=0;
pS=0;

% If results folder does not exist, create it
if ~exist('results', 'dir')
    mkdir('results');
end

% Demograph info
p.subjectcode = input('Subject code [9999]: '); if isempty(p.subjectcode); p.subjectcode=9999; end
p.paramName = ['../results/' p.taskName '_' num2str(p.subjectcode)];
if exist(['results/' p.taskName '_' num2str(p.subjectcode) '_params.mat'], 'file')
   error('CAUTION! Param file for this subject already exists in results directory')
end
p.demo.gender = input('Gender 1=male, 2=female [1]: '); if isempty(p.demo.gender); p.demo.gender=1; end
p.demo.age = input('Age in years [99]: '); if isempty(p.demo.age); p.demo.age=99; end
p.demo.handedness = input('Handedness 1=right, 2=left [1]: '); if isempty(p.demo.handedness); p.demo.handedness=1; end

%% Initialize experiment 
% ----------------------------------------------------------
run scripts/desAndVar.m
run scripts/loadStim.m

% Store parameters
p.glob=glob;p.learn=learn;p.pred=pred;p.map=map;p.sens=sens;

%% Save params to use them in the future
save(['results/' p.taskName '_' num2str(p.subjectcode) '_params.mat'],'p')