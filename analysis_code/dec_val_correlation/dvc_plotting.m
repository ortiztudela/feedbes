%% DVC plotting
% Create plots for the correlation with decision value

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output_dir=[main_folder, '/outputs/group_level/dec_val_corr/'];

run fig_defaults.m

%% Load data
load([output_dir, 'dec_val_corr_matrix.mat'])

% Create plot
f=figure;

for c_mem=1:2
    
    if c_mem==1
        mem_lab='episodic retrievals';
        mem_data=[data(1:30,1),data(1:30,2)];
        col=[.7,.5,.7];
        mem_data(6,:)=[];
    else
        mem_lab='semantic retrievals';
        mem_data=[data(31:60,1),data(31:60,2)];
        col=[.9,.7,.2];
        mem_data(6,:)=[];
    end
    subplot(2,1,c_mem),h = notBoxPlot(mem_data,'style', 'sdline');axis([0,3,-0.4,0.4])
    d = [h.data];%xtickangle(45)
    line([0:3],[0,0,0,0],'LineStyle', '--', 'Color', 'k');%title(mem_lab);
    set(d, 'markerfacecolor', col+.1, 'color', [0,0,0],'markersize', 6);xticklabels('');
    set(h(1).sd,'Color', [.3,.3,.3]); set(h(1).semPtch,'FaceColor', col);
    set(h(2).sd,'Color', [.3,.3,.3]); set(h(2).semPtch,'FaceColor', col);
    set(h(1).mu,'Color', [0,0,0], 'LineWidth', 4);set(h(2).mu,'Color', [0,0,0], 'LineWidth', 4);
    
    for i=1:2
        [p_val,hip,stats] = signrank(mem_data(:,i),0,'tail','right');
        if p_val<.001;text(i,.3,'**', 'FontSize', 20);
        elseif p_val<.05;text(i,.3,'*', 'FontSize', 20);end
    end
end

set(f,'PaperPosition',[0,0,6,12])
saveas(gcf,[main_folder, '/figures/group_level/dec_val_corr/_dec_val_corr.jpg'])
