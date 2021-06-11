%% RSA analyses with TDT
%% ############## Experiment info ##############
%#######  Event-related design: 16 scenes and 4 objects.
% Pairing between scenes and objects is counterbalanced
% across participants. CB of labels is performed in the
% feedBES_desMat_runs script.

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])

% Out name
output_file=[main_folder, '/outputs/group_level/RSA/RDMs_objsort.mat'];
sufs.figures = [main_folder,'/figures/group_level/decoding/'];

use_rois=1:12;
use_subject=[1:5,7:30]; % Beastie

%% Specify what to run
run_RSA=0;
nROIs=numel(use_rois);
nSubs=numel(use_subject);
anal_tag={'Scn','Scn2','Places','Objs','ObjsCorr','XC',...
    'Scn_epi','Scn2_epi','Places_epi','Objs_epi','ObjsCorr_epi','XC_epi',...
    'scn_comb', 'places_comb', 'obj_comb'};
ROI_labels={'v1_rh'; 'v1_periph'; 'v1_fov'; 'v2_periph'; 'v2_fov';'vmpfc_neurosynth';'hc';'vmpfc_cortex'; 'LOC_neurosynth'; 'precuneus_neurosynth'; 'hc_left'; 'hc_right';'CA1';'DG'};
ROI_labels_plot={'v1 rh'; 'v1 periph'; 'v1 fov'; 'v2 periph'; 'v2 fov';'vmpfc neurosynth';'hc';'vmpfc'; 'LOC'; 'precuneus'; 'hc left'; 'hc right'; 'CA1';'DG'};
scn_lab={
    'livingroom', 'electronics','bathroom','bathstore', ...
    'livingroom2','electronics2', 'bathroom2', 'bathstore2',...
    'kitchen2','kitchenstore2', 'bedroom2', 'bedstore2', ...
    'kitchen','kitchenstore', 'bedroom', 'bedstore', ...
    };
run_labels=repmat([1:4],1,8)';
run_labels_tag=['run1';'run2';'run3';'run4'];
obj_lab = {'bath','bath','bed','bed','oven','oven','tv','tv'};

%% Plots info
subPlot_rows=numel(use_rois);
subPlot_cols=1;

%% Loop through subjects
plot_subjects=1;
if plot_subjects
    for cSub=use_subject
        
        % Get folder structure
        [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
        
        % State
        fprintf('Starting subject: %s\n', num2str(cSub));
        space='T1w';
        
        %% Run RSA if enabled above      
        if run_RSA
            % Gunzip nifti
            for cRun=1:4
                ['Gunzipping run ', num2str(cRun)]
                if cRun<3;ses_nb='01';elseif cRun>2;ses_nb='02';end
                
                % Check if the smoothed files exist
                if ~exist([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-preproc_bold.nii'])
                    gunzip([sufs.brain, 'ses-', ses_nb, '/func/', sub_code, '_ses-', ses_nb, '_task-feedBES_run-', num2str(cRun), '_space-',space,'_desc-preproc_bold.nii.gz']);
                    
                end
            end
            
            % Add necessary paths
            addpath([main_folder, '/analysis_scripts/decoding_toolbox_v3.997'])
            addpath([sufs.main, '/../../_common_software/spm12'])
            
            for cROI=use_rois
                % Get ROI label
                dataLabel=ROI_labels{cROI};
                
                % Run RSA
                feedbes_RSA(sufs, sub_code, dataLabel)
            end
        end
        
        %%  Scenes
        close all
        try
            for cROI=use_rois
                
                % Get ROI label
                dataLabel=ROI_labels{cROI};
                
                % Load output
                load([sufs.outputs, 'tdt_RSA/', dataLabel,'/res_other_average.mat'])
                
                % Store RDM
                RDM{cROI}(:,:,cSub) = diss2perc(results.other_average.output{1});
                
                % Plot individual RDMs
                subplot(3,4,cROI),imagesc(t{cROI}(:,:,cSub))
                xticks(1:6:96);yticks(1:6:96)
                xticklabels([obj_lab,obj_lab])
                yticklabels([obj_lab,obj_lab])
                xtickangle(90)
                title(ROI_labels_plot{cROI})
                
                % Save fig
                saveas(gcf,[sufs.figures, '/RDM.jpg'])
            end
        catch
            warning(['Unable to look at ', dataLabel, ' for ', num2str(cSub)])
        end
    end
    
    % Save group data
    output.RDM_sub=t;
    save(output_file, 'output')
end

%% Compute average RDM
load(output_file)
RDM=output.RDM_sub;
f=figure;
for cROI=use_rois
    figure(9998)
    av_RDM{cROI} = mean(RDM{cROI},3);
    
    % Plot individual RDMs
    subplot(3,4,cROI),imagesc(av_RDM{cROI})
    xticks(1:6:96);yticks(1:6:96)
    xticklabels([obj_lab, obj_lab])
    yticklabels([obj_lab, obj_lab])
    xtickangle(90)
    title(ROI_labels_plot{cROI})
    
end
set(f,'PaperPosition',[0,0,20,15]) %Just to make save to disk consistent
saveas(gcf,[main_folder, '/figures/group_level/RSA/group_RDM.jpg'])

% Include average group data
output.RDM_sub=RDM;
output.RDM_group=av_RDM;
save(output_file, 'output')