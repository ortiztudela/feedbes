%% FeedBES PPI Analysis - Script 00 - Create condition files (per run) for FSL
%
% Authors: Javier Ortiz-Tudela feat. Isabelle Ehrlich
% Lifespan Cognitive and Brain Development (LISCO) Lab
% Goethe University Frankfurt am Main
%
%% Description
%
% This script creates .txt files needed for the 1st level design file for each
% participant (we have 30), each condition (episem & semepi), and each run (we have 4). 
%
% The resulting .txt files are 3-column format regressors that represent: 
% 1. the contrast A-B which is called xxx_minus.txt
%    1st column: trials of A  
%    2nd column: trials of B
%    3rd column: weight (1 for A and -1 for B)
%
% 2. the contrast A+B which is called xxx_plus.txt
%    1st column: trials of A
%    2nd column: trials of B
%    3rd column: weight (1 for bothm, A and B)
%
%% Go!

% Get the path to the main folder
if strcmpi(getenv('USERNAME'),'ehrlich')                                    %strcmpi(S1,S2) compares S1 and S2 and returns either 1 (true) or 0 (false)
    main_folder= '/home/ehrlich/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USERNAME'),'ortiz')
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
elseif strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
end

% Which participants do you want to run?
which_sub=[1:30];

% Which contrast?
episem=1; % 1 for episem (episodic > semantic); 2 for semepi (semantic > episodic)

% start looping over participants
for cSub = which_sub 
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    conv_labels=[];
    
    for cRun = 1:4 % start looping over the 4 runs
        
        % Load task outputs
        load([sufs.beh, 'feedBES_', num2str(cSub), '_run', num2str(cRun),'_data.mat']);
        load([sufs.beh, 'feedBES_', num2str(cSub), '_params.mat']);
        
        % Turn string labels into numbers (and handle counterbalancing)
        labels=unique(p.pred.scn_labels);
        [~,conv_labels(:,cRun),~]=feedBES_desMat_runs(sufs, cSub, cRun, [], []);
        
        % Re-code the trials in episodic and semantic trials
        episem_labels=zeros(length(conv_labels(:,cRun)),1);
        if episem==1
            episem_labels(conv_labels(:,cRun)<10)=1;
            episem_labels(conv_labels(:,cRun)>10)=-1;
        elseif episem==2
            episem_labels(conv_labels(:,cRun)<10)=-1;
            episem_labels(conv_labels(:,cRun)>10)=1;
        end
        
        % Write minus event file (3 column matrix) to preferred location
        cool_matrix=table(r.trialOnset+4.8,[r.trialOffset-r.trialOnset],episem_labels);
        if episem==1
            writetable(cool_matrix, [sufs.outputs, 'PPI_results/Cond_files/', sub_code, '_run', num2str(cRun), '_episem_minus.txt'], 'WriteVariableNames', 0, 'Delimiter', ' ')
        elseif episem==2
            writetable(cool_matrix, [sufs.outputs, 'PPI_results/Cond_files/', sub_code, '_run', num2str(cRun), '_semepi_minus.txt'], 'WriteVariableNames', 0, 'Delimiter', ' ')
        end
        
        % Write plus event file (3 column matrix) to preferred location
        if cSub==13
            cool_matrix=table(r.trialOnset+4.8,[r.trialOffset-r.trialOnset],ones(128,1)); %participant 13 has 128 onsets
        else
            cool_matrix=table(r.trialOnset+4.8,[r.trialOffset-r.trialOnset],ones(96,1));
        end
        if episem==1
            writetable(cool_matrix, [sufs.outputs, 'PPI_results/Cond_files/', sub_code, '_run', num2str(cRun),  '_episem_plus.txt'], 'WriteVariableNames', 0, 'Delimiter', ' ')
        elseif episem==2
            writetable(cool_matrix, [sufs.outputs, 'PPI_results/Cond_files/', sub_code, '_run', num2str(cRun),  '_semepi_plus.txt'], 'WriteVariableNames', 0, 'Delimiter', ' ')
        end
        
    end
    
    fprintf(['subject ' num2str(cSub,'%.2d') ' done\n']) % Tell me if a particpant is done
    
end