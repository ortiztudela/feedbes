%% Project FeedBES: Feedback from Episodic and Semantic memories in early visual cortex.
% ----------------------------------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Javier Ortiz-Tudela
% ortiztudela@psych.uni-frankfurt.com
% LISCO Lab - Goethe Universität
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Additional info %%%
% This task aims at exploring the feedback signals to early visual cortex eithe
% from episodic and semantic memory traces. In this case, episodic and semantic
% are equivalent to semantically congruent and incongruent. Participants
% are first expose to a learning phase and then, retrieval is performed
% inside the scanner.
%%%%%%%%%%%%%%%%%%%%%%%

% Needs genParam.m to be run first.
clear

%% Load params for this session
p.subjectcode = input('Subject code [9999]: '); if isempty(p.subjectcode); p.subjectcode=9999; end
session= input(['Session? \n [1.Learning; 2.Scanner training; 7: Refreshment; ', ...
    '\n 3.Scanner; 4.Mapping; 5.Sensory template; 6.Post-scan]: ']); if isempty(session);error('Select a session');end
if session == 3
    cRun= input('Run number?: ');if isempty(cRun); cRun=1; end
    if exist(['results/feedBES_', num2str(p.subjectcode) '_run' num2str(cRun), '_data.mat'], 'file')
        error('CAUTION! Data for this run already exists in results folder')
    end
end
testMode = input('Test mode?[1=Yes,2=No]: '); if isempty(testMode); testMode=1; end

try
    load(['results/feedBES_' num2str(p.subjectcode) '_params.mat'])
catch
    error('Parameters not generated for this subject')
end

%% Instructions
% ----------------------------------------------------------
run scripts/setupScreen.m
run scripts/key_config.m
run scripts/createTextures.m
run scripts/feedBES_instr.m

%% Experimental blocks
% ----------------------------------------------------------

if session == 1         
    run scripts/feedBES_study.m
elseif session == 2
    run scripts/feedBES_scanner_training.m
elseif session == 3
    run scripts/feedBES_scanner.m
elseif session == 4
    run scripts/feedBES_mapping.m
elseif session == 5
    run scripts/feedBES_sensTempl.m
elseif session == 6
    run scripts/feedBES_postscan_test.m
elseif session == 7
    run scripts/feedBES_refresh.m
end
run scripts/endOfRun.m
