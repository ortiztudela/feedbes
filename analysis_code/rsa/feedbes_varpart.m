%% RSA analyses. Variance partitioning.
% Perform variance particioning and create plots.

close all
clear
%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])

% Default figure properties
run fig_defaults.m

%%
% Out name
output_file=[main_folder, '/outputs/group_level/RSA/RDMs_objsort.mat'];
sufs.figures = [main_folder,'/figures/group_level/decoding/'];

use_rois=[1:5,7:12];
use_subject=[1:5,7:30];

%% Specify what to run
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

obj_lab = {'tv','tv','bath','bath','oven','oven','bed','bed'};

%% Plots info
subPlot_rows=numel(use_rois);
subPlot_cols=1;

%% Models
load(output_file)

% Scn model: Every scene is treated differently
scn_model=  kron(eye(16),ones(1,6)); % 4 scenes, repeated 16 times
scn_model= 1 - scn_model'*scn_model;

% Obj model: Scenes paired with the same object are treated as equal
obj_model=kron(eye(8),ones(1,12));
obj_model= 1- obj_model'*obj_model;

% Obj-Noscn model
XC_model_for_plotting=(scn_model)+(obj_model);
% The former model looks nice when plotting but we need to replace same-scn
% same object with NaNs
XC_model=XC_model_for_plotting-1;
XC_model(XC_model==-1)=NaN;
XC_model(1:48,49:end)=NaN;
XC_model(49:end,1:48)=NaN;

% Include model RDMs
output.RDM_models.scn=scn_model;
output.RDM_models.obj=obj_model;
output.RDM_models.objNoScn=XC_model;
save(output_file, 'output')

%% Variance partitioning

mod_scn=scn_model(1:48,1:48);
mod_XC=XC_model(1:48,1:48);
mod_obj=obj_model(1:48,1:48);
csvwrite([main_folder, '/outputs/mod_scn.csv'], mod_scn)
csvwrite([main_folder, '/outputs/mod_obj.csv'], mod_obj)
close all

for cCond=1:2
    for cROI=use_rois
        
        % Get ROI label
        dataLabel=ROI_labels{cROI};
        
        % Loop through subjects
        for cSub=use_subject
            if cCond==1
                temp=output.RDM_sub{cROI}(1:48,1:48,cSub);
                % Write to ouput
                csvwrite([main_folder, '/outputs/group_level/RSA/epi_RDM_', ROI_labels{cROI}, '.csv'], temp)
                
            elseif cCond==2
                temp=output.RDM_sub{cROI}(49:end,49:end,cSub);
                % Write to ouput
                csvwrite([main_folder, '/outputs/group_level/RSA/sem_RDM_', ROI_labels{cROI}, '.csv'], temp)
                
            end
            try
                [scn(cSub,cROI,cCond),b(cSub,cROI,cCond),obj(cSub,cROI,cCond),d,ab,bc,Probabc,Probab,Probbc,Proba,Probc]=DistanceVariationPartition(temp, mod_scn, mod_obj, 1000,0);
                scn(cSub,cROI,cCond)=atanh(scn(cSub,cROI,cCond));
                obj(cSub,cROI,cCond)=atanh(obj(cSub,cROI,cCond));
                shared(cSub,cROI,cCond)=atanh(b(cSub,cROI,cCond));
                
            catch
                keyboard
                ['Problem with ',dataLabel]
            end
        end
    end
end

scn=scn(scn(:,1,1)~=0,:,:);
obj=obj(obj(:,1,1)~=0,:,:);
shared=shared(shared(:,1,1)~=0,:,:);


%% Plot variance partitioning
% Create bar plots and venn diagrams.

use_rois=[2:5,7:12];
for cCond=1:2
    plotCount=1;d=1;
    close all
    for cROI=use_rois([1,3])
        
        if cCond==1
            temp=output.RDM_group{cROI}(1:48,1:48);
        elseif cCond==2
            temp=output.RDM_group{cROI}(49:end,49:end);
        end
        
        % open figure            
        if cCond==1
            plot_data=output.RDM_group{cROI}(1:48,1:48);
            mem_lab='episodic';
            col=[.7,.5,.7];
        elseif cCond==2
            plot_data=output.RDM_group{cROI}(49:end,49:end);
            mem_lab='semantic';
            col=[1,.7,0.2];
        end
        
        % Get sample averages
        av_scn=squeeze(mean(scn,1));
        av_obj=squeeze(mean(obj,1));
        av_shared=squeeze(mean(shared,1));
        
        % Comptue SE (SD/sqrt(N)) Boner and Epstein
        se_scn=std(scn(:,cROI,cCond))/sqrt(size(scn,1));
        se_obj=std(obj(:,cROI,cCond))/sqrt(size(obj,1));
        
        % Draw Venn's diagram on correlation model
        fig_ven=figure(9999);
        subplot(1,2,plotCount),
        [H,S]=venn([av_scn(cROI,cCond),av_obj(cROI,cCond),av_shared(cROI,cCond)], 'FaceColor', {[.9 0 .3 ];[.1 .7 1]});
        axis('off')
        
        % Draw bar plot        
        fig1=figure(9996);set(fig1,'PaperPosition',[0,0,10,5]) % Adjust printed size
        subplot(1,2,plotCount),
        plot_data=[av_scn(cROI,cCond),av_obj(cROI,cCond)];
        bplot=bar(plot_data);
        bplot.FaceColor = 'flat';
        bplot.CData(1,:)= col;
        bplot.CData(2,:)= col;
        hold on
        
        % Plot error bar
        er = errorbar([1,2],plot_data,[se_scn,se_obj],[se_scn,se_obj]);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        
        % Format
        xticklabels('');
        ymax=bplot.Parent.YLim(2);
        ylim([0-ymax*.2, ymax])
        
        % Stats
        [p,h,stats] = signrank(scn(:,cROI,cCond),obj(:,cROI,cCond),'tail','both');
        if p<.001;text(1.3,ymax*.93,'**', 'FontSize', 25);line([0.9,2.1],[ymax*.9,ymax*.9],'col', 'k');elseif p<.05;text(1.4,ymax*.93,'*', 'FontSize', 25);line([0.9,2.1],[ymax*.9,ymax*.9],'col', 'k');end
        text(1,ymax*-.1,'*', 'FontSize', 25, 'Color', 'r');
        if cCond==1
         text(2,ymax*-.1,'*', 'FontSize', 25, 'Color', 'r');
        end

        
        plotCount=plotCount+1;
    end
    
    % Save fig
    figure(fig1)
    set(fig1,'PaperPosition',[0,0,12,12]) %Just to make save to disk consistent)
    saveas(gcf,[main_folder, '/figures/group_level/RSA/', mem_lab, '_variance_partitioning_EVC.jpg'])
    
    
    figure(fig_ven)
    set(fig_ven,'PaperPosition',[0,0,6,6]) %Just to make save to disk consistent)
    saveas(gcf,[main_folder, '/figures/group_level/RSA/', mem_lab, '_venn.jpg'])
end
