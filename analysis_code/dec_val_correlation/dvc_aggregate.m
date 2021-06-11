function dvc_aggregate(which_sub)
% Aggregate the results from dvc_compute

%% Add necessary paths
% Main folder
if strcmpi(getenv('USERNAME'),'javier')
    main_folder= '/home/javier/pepe/2_Analysis_Folder/PIVOTAL/FeedBES';
else
    main_folder= '/home/ortiz/DATA/2_Analysis_Folder/PIVOTAL/FeedBES';
end
addpath([main_folder, '/analysis_scripts/clean/_functions'])
output_dir=[main_folder, '/outputs/group_level/dec_val_corr/'];
if ~exist(output_dir)
    mkdir(output_dir)
end
out=[];data=[];
%% Loop through subjects
for cSub=which_sub
    
    % Get folder structure
    [sufs,sub_code]=feedBES_getdir(main_folder, cSub);
    
    sprintf(['*****************************************\n',...
        'Aggregating %s...'],sub_code)
    
    for cAnal=[3,8]
        if cAnal==3;mem_cond=1;mem_lab='epi';else;mem_cond=2;mem_lab='sem';end
        % Load results
        load([sufs.dec_corr, mem_lab, '_corr_matrix.mat'])
        
        % Store
        data(:,:,cSub, mem_cond)=corr_mat;
        
        out_mat=csvread([sufs.dec_corr, mem_lab, '_fulldata.csv']);
        out=[out;repmat(mem_cond,length(out_mat),1),out_mat];
    end
end

% We will be only looking at v1_periph
data=squeeze(data(2,:,:,:));

% Reshape to put semantic below episodic
data=reshape(data,2,size(data,2)*2);
data(end+1,:)=[1:30,1:30]; % Subject N
data(end+1,:)=[ones(1,30),ones(1,30)*2]; % Mem condition

data=data';

% Create plot
f=figure;
epi=[data(1:30,1),data(1:30,2)];
sem=[data(31:60,1),data(31:60,2)];
epi(6,:)=[];sem(6,:)=[];

subplot(1,2,1),h = notBoxPlot(epi,'style', 'sdline');axis([0,3,-0.4,0.4])
d = [h.data];xtickangle(45)
line([0:3],[0,0,0,0],'LineStyle', '--', 'Color', 'k');title('episodic retrievals');
set(d, 'markerfacecolor', [1,1,0.4], 'color', [0,0.4,0],'markersize', 6);xticklabels({'vmpfc'; 'hc'});
set(h(1).sd,'Color', [.3,.3,.3]); set(h(1).semPtch,'FaceColor', [.7,.5,.7]);
set(h(2).sd,'Color', [.3,.3,.3]); set(h(2).semPtch,'FaceColor', [.7,.5,.7]);
set(h(1).mu,'Color', [0,0,0], 'LineWidth', 4);set(h(2).mu,'Color', [0,0,0], 'LineWidth', 4);

[p_val,hip,stats] = signrank(epi(:,2),0,'tail','right');
if p_val<.001;text(2,.3,'**', 'FontSize', 20);
elseif p_val<.05;text(2,.3,'*', 'FontSize', 20);end

subplot(1,2,2),h = notBoxPlot(sem, 'style', 'sdline');axis([0,3,-0.4,0.4])
d = [h.data];xtickangle(45)
line([0:3],[0,0,0,0],'LineStyle', '--', 'Color', 'k');title('semantic retrievals');
set(d, 'markerfacecolor', [1,1,0.4], 'color', [0,0.4,0],'markersize', 6);xticklabels({'vmpfc'; 'hc'});
set(h(1).sd,'Color', [.3,.3,.3]); set(h(1).semPtch,'FaceColor', [1,.7,.2]);
set(h(2).sd,'Color', [.3,.3,.3]); set(h(2).semPtch,'FaceColor', [1,.7,.2]);
set(h(1).mu,'Color', [0,0,0], 'LineWidth', 4);set(h(2).mu,'Color', [0,0,0], 'LineWidth', 4);


set(f,'PaperPosition',[0,0,20,10]) %Just to make save to disk consistent)
saveas(gcf,[main_folder, '/figures/group_level/dec_val_corr/_dec_val_corr.jpg'])


% Now we can aggregate over participants
save([output_dir, 'dec_val_corr_matrix.mat'], 'data')
csvwrite([output_dir, 'dec_val_corr_matrix.csv'],data)
csvwrite([output_dir, 'full_data.csv'],out)
