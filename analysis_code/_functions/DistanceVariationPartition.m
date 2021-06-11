function [a,b,c,d,ab,bc,Probabc,Probab,Probbc,Proba,Probc,p_val_bc]=DistanceVariationPartition(Y,X,W,NumberPermutations,draw_venn);
% DistanceVariationPartitioning: performs a variation partitioning on a distance matrix (or similarity) Y
% based on two data distance matrices X and W. Tests of significance on fractions are performed by permutation.
% input:
%   Y = distance matrix (obs x obs) of response variables
%   X and W = distance matrices (obs x obs) of independent variables
%   NumberPermutations = Number of Permutations for the permutation test on fractions
% output:
%   a = unique fraction of variation due to matrix X
%   b = common fraction of variation between matrices X and W
%   c = unique fraction of variation due to matrix W
%   d = residual fraction
%   Probabc, Probab, Probbc, Proba and Probc = probabilities associated to fractions [abc], [ab], [bc], [a] and [c], respectively
%   Note that fraction [b] cannot be tested

% References: Legendre, P., F.-J. Lapointe & P. Casgrain. 1994. Modeling brain evolution from behavior:
%               a permutational regression approach. Evolution 48: 1487-1499.
%             Tuomisto, H., K. Ruokolainen, R. Kalliola, A. Linna, W. Dan-joy, and Z. Rodriguez. 1995.
%               Dissecting Amazonian biodiversity. Science 269: 63-66.
% author: Pedro Peres-Neto, May 2005 (pedro.peres-neto@uregina.ca)

NumberColumns=size(Y,1);

% Place distance matrices into a vector
% Check if NaNs in one of the models
YVector=Y(find(~triu(ones(NumberColumns))));
XVector=X(find(~triu(ones(NumberColumns))));
WVector=W(find(~triu(ones(NumberColumns))));

NumberRows=NumberColumns*(NumberColumns-1)/2;

% if max(max(isnan(X)))~=0 || max(max(isnan(W)))~=0
%     NaN_ind=isnan(WVector);
%     NumberColumns=NumberColumns-5;
%     YVector(NaN_ind)=[];
%     XVector(NaN_ind)=[];
%     WVector(NaN_ind)=[];
%     NumberRows=length(YVector);
% end

% Center vector of distances
YVector=YVector-ones(NumberRows,1)*mean(YVector);
XVector=XVector-ones(NumberRows,1)*mean(XVector);
WVector=WVector-ones(NumberRows,1)*mean(WVector);

% fractions observed
k=size(YVector,1); % number of observations
TotalSS=trace(YVector'*YVector);

% abc
SlopesObs=inv([XVector,WVector]'*[XVector,WVector])*[XVector,WVector]'*YVector; % in abc slopes are calculated because they will be used as the statistics in the partial Mantel
pred=[XVector,WVector]*SlopesObs;
RegressionSS=trace(pred'*pred);
abc=RegressionSS/TotalSS;
residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
regressionMS=RegressionSS/k;
FabcObs=regressionMS/residualMS;
SlopesObs=abs(SlopesObs);

% ab
slopes=inv([XVector]'*[XVector])*[XVector]'*YVector;
pred=[XVector]*slopes;
RegressionSS=trace(pred'*pred);
ab=RegressionSS/TotalSS;
residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
regressionMS=RegressionSS/k;
FabObs=regressionMS/residualMS;

% bc
slopes=inv([WVector]'*[WVector])*[WVector]'*YVector;
pred=[WVector]*slopes;
RegressionSS=trace(pred'*pred);
bc=RegressionSS/TotalSS;
residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
regressionMS=RegressionSS/k;
FbcObs=regressionMS/residualMS;

a=abc-bc;
c=abc-ab;
b=abc-a-c;
d=1-abc;

% Plot venn diag
if draw_venn
    [H,S]=venn([ab,bc],b, 'FaceColor', {[1,.5,0.1];[.5,0,.5]});
end
% permutation test
'Running permutation test'
Probabc=1; Probab=1; Probbc=1; Proba=1; Probc=1;
for i=1:NumberPermutations-1
    % Permute Distance Matrix Y
    PermutedColumns=randperm(NumberColumns);
    YPermuted=Y(PermutedColumns,:);
    YPermuted=YPermuted(:,PermutedColumns);
    % Place distance matrices into a vector
    YVector=YPermuted(find(~triu(ones(NumberColumns))));
    % Center vector
    YVector=YVector-ones(NumberRows,1)*mean(YVector);
    % abc
    SlopesRnd=inv([XVector,WVector]'*[XVector,WVector])*[XVector,WVector]'*YVector; % in abc slopes are calculated because they will be used as the statistics in the partial Mantel
    pred=[XVector,WVector]*SlopesRnd;
    RegressionSS=trace(pred'*pred);
    abc=RegressionSS/TotalSS;
    residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
    regressionMS=RegressionSS/k;
    FabcRnd=regressionMS/residualMS;
    SlopesRnd=abs(SlopesRnd);
    % ab
    slopes=inv([XVector]'*[XVector])*[XVector]'*YVector;
    pred=[XVector]*slopes;
    RegressionSS=trace(pred'*pred);
    ab=RegressionSS/TotalSS;
    residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
    regressionMS=RegressionSS/k;
    FabRnd=regressionMS/residualMS;
    % bc
    slopes=inv([WVector]'*[WVector])*[WVector]'*YVector;
    pred=[WVector]*slopes;
    RegressionSS=trace(pred'*pred);
    bc=RegressionSS/TotalSS;
    residualMS=sum((YVector-pred)'*(YVector-pred))/(k-2-1);
    regressionMS=RegressionSS/k;
    FbcRnd=regressionMS/residualMS;
    if FabcRnd >= FabcObs Probabc=Probabc+1; end;
    if FabRnd >= FabObs Probab=Probab+1; end;
    if FbcRnd >= FbcObs Probbc=Probbc+1; end;
    if SlopesRnd(1) >= SlopesObs(1) Proba=Proba+1; end;
    if SlopesRnd(2) >= SlopesObs(2) Probc=Probc+1; end;
    
    % Store results for figure
    ab_p(i)=abc-bc;
    bc_p(i)=abc-ab;
    
    % Difference
    a_minus_c(i)=ab_p(i)-bc_p(i);
    
end;
'Done'

% Manual pval
Probabc=Probabc/NumberPermutations;
Probab=Probab/NumberPermutations;
Probbc=Probbc/NumberPermutations;
Proba=Proba/NumberPermutations;
Probc=Probc/NumberPermutations;


% Comptue SE (SD/sqrt(N)) Boner and Epstein

% Signrank
[p_val_ab,h,stats]=signrank(ab_p, a);
[p_val_bc,h,stats]=signrank(bc_p, c);


% Include labels in the plot
if draw_venn
    for i = 1:3
        if i==1
            t=a;
        elseif i==2
            t=c;
        elseif i==3
            t=b;
        end
        
        text(S.ZoneCentroid(i,1), S.ZoneCentroid(i,2), num2str(round(t,3)))
    end
end


% subplot(1,3,1), k=histogram(ab_p);hold on; line([FabObs FabObs],[0 max(k.Values)], 'col', 'r')
% subplot(1,3,2), k=histogram(abc_p);hold on; line([FabcObs FabcObs],[0 max(k.Values)], 'col', 'r')
% subplot(1,3,3), k=histogram(bc_p);hold on; line([FbcObs FbcObs],[0 max(k.Values)], 'col', 'r')
