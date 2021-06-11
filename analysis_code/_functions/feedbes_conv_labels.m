function [conv_labels]=feedbes_conv_labels(cSub, original_labels)
%% Turn scene names into numbers

% Pre-allocate
conv_labels = zeros(length(original_labels),1);

% Counterbalance scenes labels across subjects
if mod(cSub,2)==1
    
    tmp = original_labels;
    conv_labels(strcmp(tmp, 'livingroom'))=1;
    conv_labels(strcmp(tmp, 'electronics'))=11;
    conv_labels(strcmp(tmp, 'bathroom'))=3;
    conv_labels(strcmp(tmp, 'bathstore'))=13;
    conv_labels(strcmp(tmp, 'kitchen'))=15;
    conv_labels(strcmp(tmp, 'kitchenstore'))=5;
    conv_labels(strcmp(tmp, 'bedroom'))=17;
    conv_labels(strcmp(tmp, 'bedstore'))=7;
    conv_labels(strcmp(tmp, 'livingroom2'))=2;
    conv_labels(strcmp(tmp, 'electronics2'))=12;
    conv_labels(strcmp(tmp, 'bathroom2'))=4;
    conv_labels(strcmp(tmp, 'bathstore2'))=14;
    conv_labels(strcmp(tmp, 'kitchen2'))=16;
    conv_labels(strcmp(tmp, 'kitchenstore2'))=6;
    conv_labels(strcmp(tmp, 'bedroom2'))=18;
    conv_labels(strcmp(tmp, 'bedstore2'))=8;
    
elseif mod(cSub,2)==0
    tmp = original_labels;
    conv_labels(strcmp(tmp, 'livingroom'))=11;
    conv_labels(strcmp(tmp, 'electronics'))=1;
    conv_labels(strcmp(tmp, 'bathroom'))=13;
    conv_labels(strcmp(tmp, 'bathstore'))=3;
    conv_labels(strcmp(tmp, 'kitchen'))=5;
    conv_labels(strcmp(tmp, 'kitchenstore'))=15;
    conv_labels(strcmp(tmp, 'bedroom'))=7;
    conv_labels(strcmp(tmp, 'bedstore'))=17;
    conv_labels(strcmp(tmp, 'livingroom2'))=12;
    conv_labels(strcmp(tmp, 'electronics2'))=2;
    conv_labels(strcmp(tmp, 'bathroom2'))=14;
    conv_labels(strcmp(tmp, 'bathstore2'))=4;
    conv_labels(strcmp(tmp, 'kitchen2'))=6;
    conv_labels(strcmp(tmp, 'kitchenstore2'))=16;
    conv_labels(strcmp(tmp, 'bedroom2'))=8;
    conv_labels(strcmp(tmp, 'bedstore2'))=18;
end
end