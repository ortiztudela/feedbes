%% RSA analyses. Model correlation.

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

%% Correlate models
run_corr_with_model=1
if run_corr_with_model
    corrWithModel=[];figure;
    
    vec_scn=reshape(scn_model(1:48,1:48), [48*48,1]);
    vec_XC=reshape(XC_model(1:48,1:48), [48*48,1]);
    vec_obj=reshape(obj_model(1:48,1:48), [48*48,1]);
    corrModelWithAv=0;corrModelWithSub=~corrModelWithAv;
    for cROI=use_rois
        
        % Get ROI label
        dataLabel=ROI_labels{cROI};
        
        % Correlate
        if corrModelWithAv
            
            % Episodic
            vec_RDM=reshape(av_RDM{cROI}(1:48,1:48),[48*48,1]);
            [corrWithModel{cROI}(1), p]=corr(vec_RDM,vec_scn, 'Type', 'Spearman');
            [corrWithModel{cROI}(2), p]=corr(vec_RDM,vec_obj, 'Type', 'Spearman');
            [corrWithModel{cROI}(3), p]=corr(vec_RDM,vec_XC, 'Type', 'Spearman','rows','complete');p
            plot_corr_epi(1,cROI)=corrWithModel{cROI}(1);
            plot_corr_epi(2,cROI)=corrWithModel{cROI}(2);
            plot_corr_epi(3,cROI)=corrWithModel{cROI}(3);
            
            
            % Semantic
            vec_RDM=reshape(av_RDM{cROI}(49:end,49:end),[48*48,1]);
            [corrWithModel{cROI}(1), p]=corr(vec_RDM,vec_scn, 'Type', 'Spearman');
            [corrWithModel{cROI}(2), p]=corr(vec_RDM,vec_obj, 'Type', 'Spearman');
            [corrWithModel{cROI}(3), p]=corr(vec_RDM,vec_XC, 'Type', 'Spearman','rows','complete');p
            plot_corr_sem(1,cROI)=corrWithModel{cROI}(1);
            plot_corr_sem(2,cROI)=corrWithModel{cROI}(2);
            plot_corr_sem(3,cROI)=corrWithModel{cROI}(3);
            
        elseif corrModelWithSub
            temp=[];
            
            for cSub=use_subject
                % Episodic
                vec_RDM=reshape(output.RDM_sub{cROI}(1:48,1:48,cSub),[48*48,1]);
                
                [corrWithModel.epi{cROI}(cSub, 1)]=corr(vec_RDM,vec_scn, 'Type', 'Spearman');
                [corrWithModel.epi{cROI}(cSub, 2)]=corr(vec_RDM,vec_obj, 'Type', 'Spearman');
                [corrWithModel.epi{cROI}(cSub, 3)]=corr(vec_RDM,vec_XC, 'Type', 'Spearman','rows','complete');
                
                % Semantic
                vec_RDM=reshape(output.RDM_sub{cROI}(49:end,49:end,cSub),[48*48,1]);
                
                [corrWithModel.sem{cROI}(cSub, 1)]=corr(vec_RDM,vec_scn, 'Type', 'Spearman');
                [corrWithModel.sem{cROI}(cSub, 2)]=corr(vec_RDM,vec_obj, 'Type', 'Spearman');
                [corrWithModel.sem{cROI}(cSub, 3)]=corr(vec_RDM,vec_XC, 'Type', 'Spearman','rows','complete');
                
            end
            
            % Fischer Z-score everything to be able to do stats
            nonZero=corrWithModel.sem{cROI}(:, 1)~=0;
            corrWithModel.epi{cROI}(nonZero, 1)=atanh(corrWithModel.epi{cROI}(nonZero, 1));
            corrWithModel.epi{cROI}(nonZero, 2)=atanh(corrWithModel.epi{cROI}(nonZero, 2));
            corrWithModel.epi{cROI}(nonZero, 3)=atanh(corrWithModel.epi{cROI}(nonZero, 3));
            
            corrWithModel.sem{cROI}(nonZero, 1)=atanh(corrWithModel.sem{cROI}(nonZero, 1));
            corrWithModel.sem{cROI}(nonZero, 2)=atanh(corrWithModel.sem{cROI}(nonZero, 2));
            corrWithModel.sem{cROI}(nonZero, 3)=atanh(corrWithModel.sem{cROI}(nonZero, 3));
            
            % Re-structure for plotting
            plot_corr_epi(:,cROI,1)=corrWithModel.epi{cROI}(nonZero, 1);
            plot_corr_epi(:,cROI,2)=corrWithModel.epi{cROI}(nonZero, 2);
            plot_corr_epi(:,cROI,3)=corrWithModel.epi{cROI}(nonZero, 3);
            plot_corr_sem(:,cROI,1)=corrWithModel.sem{cROI}(nonZero, 1);
            plot_corr_sem(:,cROI,2)=corrWithModel.sem{cROI}(nonZero, 2);
            plot_corr_sem(:,cROI,3)=corrWithModel.sem{cROI}(nonZero, 3);
            
        end
        
    end
 
end

%% Little excursion to create another plot %%%%%
c=1;f=figure;set(f,'PaperPosition',[0,0,20,15]) %Just to make save to disk consistent)

vec_scn=reshape(scn_model(1:48,1:48), [48*48,1]);
vec_XC=reshape(XC_model(1:48,1:48), [48*48,1]);
% vec_obj=reshape(obj_model(1:48,1:48), [48*48,1]);
av_RDM=output.RDM_group;
for cROI=use_rois([2,4])
    
    % Plot group level RDMs
    subplot(2,4,c:c+1),imagesc(av_RDM{cROI})
    xticks(1:6:96);yticks(1:6:96)
    xticklabels([obj_lab,obj_lab])
    yticklabels([obj_lab,obj_lab])
    xtickangle(90)
%     title(ROI_labels_plot{cROI})
    
    % Split trials by mem condition and correlate at the group level
    epiRDM=av_RDM{cROI}(1:48,1:48);
    semRDM=av_RDM{cROI}(49:end,49:end);
    vec_epi=reshape(epiRDM,[48*48,1]);vec_sem=reshape(semRDM,[48*48,1]);
    
    [corr_model_mem{cROI}(1,1), ep]=corr(vec_epi,vec_scn, 'Type', 'Spearman','rows','complete');
    [corr_model_mem{cROI}(2,1), sp]=corr(vec_sem,vec_scn, 'Type', 'Spearman','rows','complete');
    
    epiRDM=av_RDM{cROI}(1:48,1:48);
    semRDM=av_RDM{cROI}(49:end,49:end);
    vec_epi=reshape(epiRDM,[48*48,1]);vec_sem=reshape(semRDM,[48*48,1]);
    [corr_model_mem{cROI}(1,2), ep]=corr(vec_epi,vec_XC, 'Type', 'Spearman','rows','complete');
    [corr_model_mem{cROI}(2,2), sp]=corr(vec_sem,vec_XC, 'Type', 'Spearman','rows','complete');
    
    % Plot correlations
    for i=0:1
        
        % Chose data and plot
        if i==0
            temp=[plot_corr_epi(:,cROI,1),plot_corr_sem(:,cROI,1)];
            model_tag='Concurrent';
        else
            temp=[plot_corr_epi(:,cROI,3),plot_corr_sem(:,cROI,3)];
            model_tag='Memory';
        end
        subplot(2,4,4+c+i), t=notBoxPlot(temp,'style', 'sdline');
        
        % Format plot
        d = [t.data];
        set(d, 'markerfacecolor', [1,1,0.4], 'color', [0,0.4,0],'markersize', 4);
        set(t(1).sd,'Color', [.3,.3,.3])
        set(t(2).sd,'Color', [.3,.3,.3])
        set(t(1).semPtch,'FaceColor', [.7,.5,.7])
        set(t(2).semPtch,'FaceColor', [1,.7,.2])
%         title(model_tag)
        axis([0,3,-0.2,.8]);xticklabels('');%xticklabels({'episodic'; 'semantic'});xtickangle(45)
        line([0,4],[0,0], 'LineStyle', '--', 'col', 'k')
        
        % Stats against 0
        [p,h,stats] = signrank(temp(:,1),0,'tail','right');
        if p<.001;text(1,-0.1,'*', 'FontSize', 25,'Color', 'r');elseif p<.05;text(1,-.1,'**', 'FontSize', 25,'Color', 'r');end
        [p,h,stats] = signrank(temp(:,2),0,'tail','right');
        if p<.001;text(2,-.1,'*', 'FontSize', 25,'Color', 'r');elseif p<.05;text(1,-.1,'**', 'FontSize', 25,'Color', 'r');end
        % Pwc
        [p,h,stats] = signrank(temp(:,1),temp(:,2),'tail','right');
        if p<.001;text(1.4,.75,'*', 'FontSize', 25);line([1:2],[.73,.73]);
        elseif p<.05;text(1.4,.75,'**', 'FontSize', 25);line([1:2],[.73,.73]);end
        
        
    end
    
    % Update counter
    c=c+2;
end
set(f,'PaperPosition',[0,0,12,12]) %Just to make save to disk consistent)

saveas(gcf,[main_folder, '/figures/group_level/RSA/_paper_RSA_2nd.jpg'])



% WORK FROM HERE
%% Little excursion to separate plot for non EVC ROIs %%%%%
c=1;%f=figure;set(f,'PaperPosition',[0,0,20,15]) %Just to make save to disk consistent)

vec_scn=reshape(scn_model(1:48,1:48), [48*48,1]);
vec_XC=reshape(XC_model(1:48,1:48), [48*48,1]);
vec_obj=reshape(obj_model(1:48,1:48), [48*48,1]);
av_RDM=output.RDM_group;
for cROI=use_rois(6:end)
    
    % Plot individual RDMs
    subplot(2,12,c:c+1),imagesc(av_RDM{cROI})
    xticks(1:6:96);yticks(1:6:96)
    xticklabels([obj_lab,obj_lab])
    yticklabels([obj_lab,obj_lab])
    xtickangle(90)
    title(ROI_labels_plot{cROI})
    
    % Split trials by mem condition
    epiRDM=av_RDM{cROI}(1:48,1:48);
    semRDM=av_RDM{cROI}(49:end,49:end);
    vec_epi=reshape(epiRDM,[48*48,1]);vec_sem=reshape(semRDM,[48*48,1]);
    
    [corr_model_mem{cROI}(1,1), ep]=corr(vec_epi,vec_scn, 'Type', 'Spearman','rows','complete');ep
    [corr_model_mem{cROI}(2,1), sp]=corr(vec_sem,vec_scn, 'Type', 'Spearman','rows','complete');sp
    
    epiRDM=av_RDM{cROI}(1:48,1:48);
    semRDM=av_RDM{cROI}(49:end,49:end);
    vec_epi=reshape(epiRDM,[48*48,1]);vec_sem=reshape(semRDM,[48*48,1]);
    [corr_model_mem{cROI}(1,2), ep]=corr(vec_epi,vec_XC, 'Type', 'Spearman','rows','complete');ep
    [corr_model_mem{cROI}(2,2), sp]=corr(vec_sem,vec_XC, 'Type', 'Spearman','rows','complete');sp
    
    % Plot correlations
    for i=0:1
        
        % Chose data and plot
        if i==0
            temp=[plot_corr_epi(:,cROI,1),plot_corr_sem(:,cROI,1)];
            model_tag='Scn model';
        else
            temp=[plot_corr_epi(:,cROI,3),plot_corr_sem(:,cROI,3)];
            model_tag='XC model';
        end
        subplot(2,12,12+c+i), t=notBoxPlot(temp);
        
        % Format plot
        d = [t.data];
        set(d, 'markerfacecolor', [1,1,0.4], 'color', [0,0.4,0],'markersize', 4);
        set(t(1).sdPtch,'FaceColor', [.9,.6,.9])
        set(t(2).sdPtch,'FaceColor', [1,.8,.2])
        set(t(1).semPtch,'FaceColor', [.5,0,.5])
        set(t(2).semPtch,'FaceColor', [1,.5,0.1])
        title(model_tag)
        axis([0,3,-0.2,.8]);xticklabels({'epi'; 'sem'});xtickangle(45)
        line([0,4],[0,0], 'LineStyle', '--', 'col', 'k')
        
        % Stats
        if ttest(temp(:,1), 0);text(1,.7,'*', 'FontSize', 15);end
        if ttest(temp(:,2), 0);text(2,.7,'*', 'FontSize', 15);end
        if ttest(temp(:,1), temp(:,2));text(1.5,.75,'*', 'FontSize', 15);
            line([1:2],[.73,.73]);end
        
    end
    
    % Update counter
    c=c+2;
    saveas(gcf,[main_folder, '/figures/group_level/RSA/_paper_RSA_2nd_source.jpg'])
end

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
                [scn(cSub,cROI,cCond),b(cSub,cROI,cCond),obj(cSub,cROI,cCond),d,ab,bc,Probabc,Probab,Probbc,Proba,Probc]=DistanceVariationPartition(temp, mod_scn, mod_obj, 100,0);
                scn(cSub,cROI,cCond)=atanh(scn(cSub,cROI,cCond));
                obj(cSub,cROI,cCond)=atanh(obj(cSub,cROI,cCond));

            catch
                keyboard
                ['Problem with ',dataLabel]
            end
        end
    end
end

%% Plot variance partitioning
% close all
use_rois=[2:5,7:12];
for cCond=1:2
    plotCount=1;d=1;
    
    for cROI=use_rois(1:4)
        
        if cCond==1
            temp=output.RDM_group{cROI}(1:48,1:48);
        elseif cCond==2
            temp=output.RDM_group{cROI}(49:end,49:end);
        end
        
        % open figure
        if cCond==1
            fig1=figure(9996);set(fig1,'PaperPosition',[0,0,15,10]) % Adjust printed size
            plot_data=output.RDM_group{cROI}(1:48,1:48);
            mem_lab='episodic';
        elseif cCond==2
            fig2=figure(9997);set(fig2,'PaperPosition',[0,0,15,10]) % Adjust printed size
            plot_data=output.RDM_group{cROI}(49:end,49:end);
            mem_lab='semantic';
        end
        
        
        % Draw Venn's diagram on correlation model
        %         subplot(2,4,plotCount),
        [a,b,c,d,ab,bc,Probabc,Probab,Probbc,Proba,Probc,pval_bc(cROI)]=DistanceVariationPartition(temp, mod_scn, mod_obj, 5000,0);
        subplot(2,5,plotCount),
        bar(1,a, 'FaceColor', 'r', 'FaceAlpha', .4);hold on
        bar(2,c, 'FaceColor', 'b', 'FaceAlpha', .4)
        xticks([1:2]);xticklabels({'scn'; 'obj'})
        
        % Draw bar plot
        %         subplot(1,4,plotCount),
        %         t=notBoxPlot([scn(:,cROI,cCond),obj(:,cROI,cCond)]);
        
        % Format plot
        %         d = [t.data];
        %         set(d, 'markerfacecolor', [1,1,0.4], 'color', [0,0.4,0],'markersize', 4);
        %         set(t(2).sdPtch,'FaceColor', [.9,.6,.9])
        %         set(t(1).sdPtch,'FaceColor', [1,.8,.2])
        %         set(t(2).semPtch,'FaceColor', [.5,0,.5])
        %         set(t(1).semPtch,'FaceColor', [1,.5,0.1])
        xticklabels({'scn'; 'obj'});xtickangle(45)%axis([0,3,-0.1,.2]);
        line([0,4],[0,0], 'LineStyle', '--', 'col', 'k')
        title(ROI_labels_plot{cROI});sgtitle(mem_lab);
        
        % Stats
        nonZero=scn(:, cROI)~=0;
%         yyaxis right; ylim([0,1]);yticks=[0,.5,1]; yticklabels={'dadf';'adad';'adada'};
%         ax = gca;
%         ax.YAxis(2).Color = [1,1,1];
        %         if ttest(scn(nonZero,cROI),0)==1; text(1,.9, '*', 'FontSize', 15);end
        if Proba<0.001; text(1,.9, '*', 'FontSize', 15);end
        
        %         if ttest(obj(nonZero,cROI),0)==1; text(2,.9, '*', 'FontSize', 15);end
        if Probc<0.001; text(2,.9, '*', 'FontSize', 15);end
        Probc
        plotCount=plotCount+1;
        
    end
    
    % Save fig
    saveas(gcf,[main_folder, '/figures/group_level/RSA/', mem_lab, '_variance_partitioning_EVC.jpg'])
end
