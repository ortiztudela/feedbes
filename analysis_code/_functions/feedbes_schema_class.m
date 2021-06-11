function [selected_pairs,selected_tag,selected_nPairs]=feedbes_schema_class(which_anal)
%% Define classification scheme
% This script creates the classification pairs.

%% Different scene-different object. Muckli and Smith (2010, PNAS).
pairs=[1,3;1,5;1,7;3,5;3,7;5,7;
    2,4;2,6;2,8;4,6;4,8;6,8];
class_anal{1}.pairs=pairs;
class_anal{1}.anal_tag= 'diff scn-diff obj';
nPairs{1}=size(pairs,1);

%% Different scene-same object. Scene-only information.
pairs=[1,2; 3,4; 5,6; 7,8];
class_anal{2}.pairs=pairs;
class_anal{2}.anal_tag= 'diff scn-same obj';
nPairs{2}=size(pairs,1);

%% Classify objects. Different scenes paired with the same object are
%% combined to obtain object only information.
% Pairs in the same row will be merged in the main script.
pairs=[1,2;
    3,4;
    5,6;
    7,8];
c=1;temp=[];
how_many=[3,2,1,0];
for i=1:size(pairs,1)
    for j=1:how_many(i)
        temp(1,:,c)=pairs(i,:);
        temp(2,:,c)=pairs(i+j,:);
        c=c+1;
    end
end
pairs=temp;
class_anal{3}.pairs=pairs;
class_anal{3}.anal_tag= 'objects';
nPairs{3}=size(pairs,3);

%combnk(v,k) would do this in a way more elegant fashion (and less error
%prone)

%% Classify objects correction. Pairs from object classifcation are broken 
%here so that if there is any unexpected learning, it should also appear here.
%Pairs in the same row will be merged in the main script.
pairs=[1,3;
    2,4;
    5,7;
    6,8];
c=1;temp=[];
how_many=[3,2,1,0];
for i=1:size(pairs,1)
    for j=1:how_many(i)
        temp(1,:,c)=pairs(i,:);
        temp(2,:,c)=pairs(i+j,:);
        c=c+1;
    end
end
pairs=temp;
class_anal{4}.pairs=pairs;
class_anal{4}.anal_tag= 'objectsCorr';
nPairs{4}=size(pairs,3);

%% Cross classification
pairs=[];
% Pairs arrangement looks here similar to that of the object correction class. 
% However, this arrangement is treated differently in the main script. Pairs on each
% third dimmension are classified against each other: the first row is
% used for training and the second one for testing. On 29/01/21 I put the 
% XC switch here since I could not find it in the main script and the
% output does not include all the decision values for all the intended
% observations.
pairs(1,:,1)=[1,3];
pairs(1,:,2)=[1,5];
pairs(1,:,3)=[1,7];
pairs(1,:,4)=[3,5];
pairs(1,:,5)=[3,7];
pairs(1,:,6)=[5,7];
pairs(2,:,:)=pairs(1,:,:)+1;
pairs(1,:,7:12)=pairs(2,:,1:6);
pairs(2,:,7:12)=pairs(1,:,1:6);
class_anal{5}.pairs=pairs;
class_anal{5}.anal_tag= 'XC';
nPairs{5}=size(pairs,3);

%% Semantic 
% If the relation between scenes is the same, we can extrapolate from the
% episodic ones
for i=1:5
    
    class_anal{5+i}.pairs=class_anal{i}.pairs+10;
    class_anal{5+i}.anal_tag= [class_anal{i}.anal_tag, '_sem'];
    nPairs{5+i}=nPairs{i};
    
end

%% Combining both memory conditions
% Scenes
pairs=[
    1,17;
    2,18;
    3,11;
    4,12;
    5,13;
    6,14;
    7,15;
    8,16;
    ];
c=1;temp=[];
how_many=[7,6,5,4,3,2,1,0];
for i=1:size(pairs,1)
    for j=1:how_many(i)
        temp(1,:,c)=pairs(i,:);
        temp(2,:,c)=pairs(i+j,:);
        c=c+1;
    end
end
pairs=temp;
class_anal{11}.pairs=pairs;
class_anal{11}.anal_tag= 'scns_combined';
nPairs{11}=size(pairs,3);

% Objects
pairs=[1,2,11,12;
    3,4,13,14;
    5,6,15,16;
    7,8,17,18];
c=1;temp=[];
how_many=[3,2,1,0];
for i=1:size(pairs,1)
    for j=1:how_many(i)
        temp(1,:,c)=pairs(i,:);
        temp(2,:,c)=pairs(i+j,:);
        c=c+1;
    end
end
pairs=temp;
class_anal{12}.pairs=pairs;
class_anal{12}.anal_tag= 'objects combined';
nPairs{12}=size(pairs,3);

%% Select the appropriate one
selected_pairs=class_anal{which_anal}.pairs;
selected_tag=class_anal{which_anal}.anal_tag;
selected_nPairs=nPairs{which_anal};


