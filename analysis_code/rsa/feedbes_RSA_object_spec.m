%% Object specific reinstatement (RSA)
% This script computes the object specific reinstatement index from
% dissimilarity scores and creates plots.

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

use_rois=[2:5,7:9];
use_subject=[1:5,7:30]; % Beastie

%% Specify what to run
nROIs=numel(use_rois);
nSubs=numel(use_subject);
anal_tag={'Scn','Scn2','Places','Objs','ObjsCorr','XC',...
    'Scn_epi','Scn2_epi','Places_epi','Objs_epi','ObjsCorr_epi','XC_epi',...
    'scn_comb', 'places_comb', 'obj_comb'};
ROI_labels={'v1_rh'; 'v1_periph'; 'v1_fov'; 'v2_periph'; 'v2_fov';'vmpfc_neurosynth';'hc';'vmpfc_cortex'; 'LOC_neurosynth'; 'precuneus_neurosynth'; 'hc_left'; 'hc_right';'CA1';'DG'};
ROI_labels_plot={'v1 rh'; 'v1'; 'v1 fov'; 'v2'; 'v2 fov';'vmpfc neurosynth';'hc';'vmpfc'; 'LOC'; 'precuneus'; 'hc left'; 'hc right'; 'CA1';'DG'};
scn_lab={
    'livingroom', 'electronics','bathroom','bathstore', ...
    'livingroom2','electronics2', 'bathroom2', 'bathstore2',...
    'kitchen2','kitchenstore2', 'bedroom2', 'bedstore2', ...
    'kitchen','kitchenstore', 'bedroom', 'bedstore', ...
    };
run_labels=repmat([1:4],1,8)';
run_labels_tag=['run1';'run2';'run3';'run4'];

obj_lab = {'tv','tv','bath','bath','oven','oven','bed','bed'};

for cSub=1:numel(use_subject)
    sub_lab{cSub}=num2str(use_subject(cSub));
end

%% Plots info
subPlot_rows=numel(use_rois);
subPlot_cols=1;

%% Assess means within scene and between scenes
load(output_file)

for cROI=use_rois
    for cSub=use_subject
        
        for cCond=1:2
            %% Current sub
            if cCond==1 % EPISODIC
                data=output.RDM_sub{cROI}(1:48,1:48,cSub);
            elseif cCond==2 % SEMANTIC
                data=output.RDM_sub{cROI}(49:end,49:end,cSub);
            end
            
            % Initialize
            selector=zeros(length(data)); same=[];within=[];between=[];c=1;
            
            % Loop throguh objects
            for i=1:12:48
                %%%USE MODELS%%%%
                % Indices obj1
                same_ind=i:i+5;
                within_ind=same_ind+6;
                selector=zeros(length(data));
                selector(:,same_ind)=ones(length(data),6)*3;
                selector(same_ind,same_ind)=1;
                selector(within_ind,same_ind)=2;
                subplot(2,4,c), imagesc(selector)
                
                % Compute average disssim
                same(c)=mean(mean(data(selector==1)));
                within(c)=mean(mean(data(selector==2)));
                between(c)=mean(mean(data(selector==3)));
                c=c+1;
                
                % Indices obj2
                within_ind=i:i+5;
                same_ind=within_ind+6;
                selector=zeros(length(data));
                selector(:,same_ind)=ones(length(data),6)*3;
                selector(same_ind,same_ind)=1;
                selector(within_ind,same_ind)=2;
                subplot(2,4,c), imagesc(selector)
                
                % Compute average disssim
                same(c)=mean(mean(data(selector==1)));
                within(c)=mean(mean(data(selector==2)));
                between(c)=mean(mean(data(selector==3)));
                c=c+1;
            end
            
            % Store averages
            if cCond==1
                % Get sub averages
                output.averages.same(cSub)=mean(same);
                output.averages.within(cSub)=mean(within);
                output.averages.between(cSub)=mean(between);
            elseif cCond==2
                % Get sub averages
                output.averages.sameSem(cSub)=mean(same);
                output.averages.withinSem(cSub)=mean(within);
                output.averages.betweenSem(cSub)=mean(between);
            end
            
        end
    end
    
    %% Computes object specific information index
    obj_spec(:,cROI)=output.averages.between-output.averages.within;
    obj_specSem(:,cROI)=output.averages.betweenSem-output.averages.withinSem;
    scn_spec(:,cROI)=output.averages.between-output.averages.same;
    scn_specSem(:,cROI)=output.averages.betweenSem-output.averages.sameSem;
    
    %% Plots (overall)
    f=figure;
    for cCond=1:2
        
        % Chose data to plot
        if cCond==1
            full=[output.averages.same', output.averages.within', ...
                output.averages.between'];
            mem_tag='(episodic)';
        elseif cCond==2
            full=[output.averages.sameSem', output.averages.withinSem', ...
                output.averages.betweenSem'];
            mem_tag='(semantic)';
        end
    end
    
end

%% Plots (object specific info index)
f=figure;
use_rois=[9,2,4];
for i=1:2
    
    % Selet data for plotting
    if i==1
        data=obj_spec;
        ax_limits=[0,numel(use_rois)+1,-20,40];title_lab='episodic';col=[.7,.5,.7];col2=[.7,.2,.7];
    elseif i==2
        data=obj_specSem;
        ax_limits=[0,numel(use_rois)+1,-20,40];title_lab='semantic';col=[.9,.7,.2];col2=[.7,.2,.7];
    elseif i==3
        data=scn_spec;
        ax_limits=[0,numel(use_rois)+1,-20,80];title_lab='episodic';col=[.7,.5,.7];col2=[1,.5,0];
    elseif i==4
        data=scn_specSem;
        ax_limits=[0,numel(use_rois)+1,-20,80];title_lab='semantic';col=[.9,.7,.2];col2=[1,.5,0];
    end
    nonZero=~data(:,2)==0;
    nonZeroCol=~data(1,:)==0;
    
    % Plot
    subplot(1,2,i), h = notBoxPlot(data(nonZero,use_rois),'style', 'sdline');   axis(ax_limits)
    
    % Format plot
    c=1;
    for cROI=use_rois
        % Stats
        [p(c),hip,stats] = signrank(data(nonZero,cROI),0,'tail','right');
        if p(c)<.001;text(c-.1,min(ax_limits)+5,'**', 'FontSize', 20, 'Color', 'r')
        elseif p(c)<.05;text(c-.1,min(ax_limits)+5,'*', 'FontSize', 20, 'Color', 'r')
        end
        set(h(c).sd,'Color', [.3,.3,.3]); set(h(c).semPtch,'FaceColor', col);
        
        % Save stats
        z(c)=stats.zval;
        c=c+1;
    end
    
    for i=1:numel(use_rois)
        set(h(i).semPtch,'EdgeColor', [1,1,1]);
        set(h(i).sd,'Color', [.3,.3,.3]);
        set(h(i).mu,'Color', [0,0,0], 'LineWidth', 4);
    end
    
    %%%LOC
    [p_val,hip,stats] = signrank(data(nonZero,9),data(nonZero,2),'tail','both');
    if p_val<.001;text(2.4,max(ax_limits)-10,'**', 'FontSize', 20);line([2,3],[max(ax_limits)-12,max(ax_limits)-12],'col', 'k');
    elseif p_val<.05;text(2.4,max(ax_limits)-10,'*', 'FontSize', 20);line([2,5],[max(ax_limits)-12,max(ax_limits)-12],'col', 'k');end
    [p_val,hip,stats] = signrank(data(nonZero,9),data(nonZero,4),'tail','both');
    if p_val<.001;text(1.8,max(ax_limits)-4,'**', 'FontSize', 20);line([1,3],[max(ax_limits)-5,max(ax_limits)-5],'col', 'k');
    elseif p_val<.05;text(1.8,max(ax_limits)-4,'*', 'FontSize', 20);line([1,3],[max(ax_limits)-5,max(ax_limits)-5],'col', 'k');end
    
    
    % Create summary matrix for stats
    p_matrix(i,:)=p';
    z_matrix(i,:)=z';
    
    line([0,numel(use_rois)+1],[0,0],'LineStyle', '--', 'Color', 'k');%title(title_lab);
    d = [h.data];xtickangle(45);%hold off;alpha(.5)
    set(d, 'markerfacecolor', col+.1, 'color', [0,0,0],'markersize', 6);xticklabels('');%xticklabels(ROI_labels_plot(use_rois));
    %     [1,1,0.4]
    % Create summary matrix by averaging across subjects
    summ_matrix=data(nonZero,nonZeroCol);
    
    % Create summary table
    summ_table=array2table(summ_matrix, 'VariableNames', ROI_labels(nonZeroCol), ...
        'RowNames', sub_lab);
    
    % Save summary table
    writetable(summ_table, [main_folder, '/outputs/group_level/RSA/obj_specific_', title_lab, '.csv'], 'WriteRowNames', 1)
    
end

%Save
set(f,'PaperPosition',[0,0,9,8] ) %Just to make save to disk consistent)
saveas(gcf,[main_folder, '/figures/group_level/RSA/_paper_RSA_index.pdf'])
