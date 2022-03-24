%% LOAD ELECTRODE DATA and .OBJ SURFACE 
clear

% load MNI brain
[vertices faces] = readObj('brain_LR.obj');
S = load ('all_elec'); 
S = struct2cell(S);
allElec = S{1};
iDD = allElec(:,1) ;

disp('electrodes imported');


%% flip to use only 1 hemisphere (optional)

for subji = 1:length(iDD)
    subjEle = iDD{subji};
    for ei = 1:length(subjEle)
       if subjEle(ei,1) > 0
           einverted  = subjEle(ei,1)*-1;
           subjEle(ei,1) = einverted;
       end
    end
    iDD{subji} = subjEle;
end


%% find electrode idx

dist2elec = 12.5; %in mm

tic
clear eIds eIdist;
for subji = 1:length(iDD)
    elec = iDD{subji};
    if ~isempty(elec)
        D = pdist2(elec,vertices)'; % distance of each vertex to each electrode
        t   = (D<dist2elec); 
        for vi = 1:length(vertices) %loop over all vertices of the model
           rowV = t(vi, :);
           rowVD = D(vi, :);
           idx = find(rowV);
           eIds{vi} = idx; % for each vertex get the id of influencing elec
           s2check = rowVD(idx); 
           eIdist{vi} =  s2check;
        end
        eIds = eIds';
        eIdist = eIdist';
    else
        eIds = [];
        eIdist = []; 
    end
    allEids{subji} = eIds;
    allEIdist{subji} = eIdist;
    
    clear eIds eIdist;
    
end

toc


%% plot electrodes

v2p = 'l'; %left or rigth

cols2use = jet(12);


figure();
%cindex = cat(1, tmean, tmean, tmean)';
vColor = ones(length(vertices), 3)-0.15;
%cindex(t1) = zeros(1,3);
pL = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData', vColor,'FaceColor','interp'); hold on;
pL.LineStyle = 'none';      % remove the lines
alpha 0.2

for subji = 1:length(iDD)
    subjEle = iDD{subji};
    for ei = 1:length(subjEle)
        [x, y, z] = sphere;
        mesh(x + subjEle(ei, 1), y +  subjEle(ei, 2) , z + subjEle(ei, 3), 'edgecolor', cols2use(subji,:)); hold on; 
    end
end


if (strcmp (v2p, 'l'))
    view(270,0)     % left orientation
    view(180,0)    
else
	view(90,0)     % right orientation
    view(180,0)    
end

l = light('Position',[-0.4 0.2 0.9],'Style','infinite');
material([.9 .3 .3]) %sets the ambient/diffuse/specular strength of the objects.


axis equal off    

%% count electrodes influencing each vertex

tic
perc2Plot = zeros (length(allEids), length(vertices));
clear elecinf
for subji = 1:length(iDD)
    for vxi = 1:length(vertices)
        if ~isempty(allEids{subji}{vxi}) 
            eId = cell2mat(allEids{subji}(vxi)); %elec id for each vertex
            elecinf(subji, vxi) = 1;
        else
            elecinf(subji, vxi) = NaN;
        end

    end
        
end


idx2c = elecinf; %idx2c = for each vertex, presence or absence of subjects
sumA = sum(idx2c, 'omitnan'); % sumA = number of subjects affecting each vertex
t = sumA; 

toc

%% plot

dat2plot        = 't'; %t or h
v2p             = 'l'; %l or r
crange          = [1 15];%[-.3 .5];

gaPow2plot      = eval (dat2plot); %h or t or sumA
gaPatch = gaPow2plot; gaPatch(isnan(gaPow2plot)) = 0;  gaPatch(gaPatch ~= 0) = NaN;
tmean_L = gaPow2plot';  tmean_LZP = cat (1, gaPatch, gaPatch, gaPatch)';


figure();
pL = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',tmean_L,'FaceColor','interp'); hold on;
pL.LineStyle = 'none';      % remove the lines

pLZP = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',tmean_LZP,'FaceColor','interp');
pLZP.LineStyle = 'none';      % remove the lines

caxis(crange)


colorMap2use = 'hot';
colormap (colorMap2use); %winter works well (also try spring)
colorbar;
if (strcmp (v2p, 'l'))
    view(270,0)     % left orientation
else
	view(90,0)     % right orientation
end

l = light('Position',[-0.4 0.2 0.9],'Style','infinite');
material([.9 .7 .3]) %sets the ambient/diffuse/specular strength of the objects.

set(gca, 'FontSize', 20)

axis equal off    
x1= pL.FaceVertexCData;
finalColors = vals2colormap(x1, colorMap2use, crange);%
finalColors (isnan(x1),:) = NaN;





%%