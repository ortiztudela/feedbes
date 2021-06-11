cd scripts
names={'livingroom';'bathroom';'kitchen';'bedroom';...
    'electronics';'bathstore';'kitchenstore';'bedstore'};

imp=1;
for i=1:8
    back=imread('stim/background.png');
    filename=names{i};
    im=imread(['stim/',filename,'.png']);
    nonZ=im~=0;back(nonZ)=0;
    full=back+im;
    subplot(4,4,imp),imagesc(full)
    title(filename)
    
    filename=[filename,'2'];
    back=imread('stim/background.png');
    im=imread(['stim/',filename,'.png']);
     nonZ=im~=0;back(nonZ)=0;
    full=back+im;
    subplot(4,4,imp+1),imagesc(full)
    imp=imp+2;
end
cd ..