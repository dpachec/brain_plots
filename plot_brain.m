%% LOAD ELECTRODE DATA and SURFACE 
%clearvars 
tic

% load MNI brain
[vertices faces] = readObj('brain_LR.obj');
S = load ('all_elec'); 
S = struct2cell(S);
allElecReal = S{1};
iDD = allElecReal(:,1) ;

disp('electrodes imported');


%% flip to use only 1 hemisphere (optional)

for subji = 1:11
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

dist4elec = 12.5; %in mm

tic
clear eIds eIdist;
fprintf('\n'); fprintf('Subject:      '); %check this later
for subji = 1:length(iDD)
    if (subji < 10) fprintf('\b\b\b'); elseif (subji < 100) fprintf('\b\b\b\b'); end
    fprintf('%d %s', subji, ' '); 
    elec = iDD{subji};
    if ~isempty(elec)
        D = pdist2(elec,vertices)';
        t   = (D<dist4elec);
        for vi = 1:length(vertices)
           rowV = t(vi, :);
           rowVD = D(vi, :);
           idx = find(rowV);
           eIds{vi} = idx; % for each vertex the id of influencing elec
           s2check = rowVD(idx); 
           eIdist{vi} =  s2check;
        end
        eIds = eIds'; % for each vertex the id of influencing elec
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


%% plot electrode electrodes

v2p = 'l' %l or r

cols = jet(12);


figure();
%cindex = cat(1, tmean, tmean, tmean)';
vColor = ones(length(vertices), 3)-0.15;
%cindex(t1) = zeros(1,3);
pL = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData', vColor,'FaceColor','interp'); hold on;
pL.LineStyle = 'none';      % remove the lines
alpha 0.2

for subji = 1:length(iDD)
    subji
    subjEle = iDD{subji};

    %use this to flip electrodes from one hemisphere 
%     for ei = 1:length(subjEle)
%        if subjEle(ei,1) > 0 %if they are on left (or right) hemisphere change
%            einverted  = subjEle(ei,1)*-1;
%            subjEle(ei,1) = einverted;
%        end
%     end
    
    for ei = 1:length(subjEle)
        [x, y, z] = sphere;
        mesh(x + subjEle(ei, 1), y +  subjEle(ei, 2) , z + subjEle(ei, 3), 'edgecolor', cols(subji,:));
        
    end
    
end



if (strcmp (v2p, 'l'))
    view(270,0)     % left orientation
    view(180,0)    
else
	view(90,0)     % right orientation
    view(180,0)    
end

%set(gca, 'CameraViewAngle', 3); %for orthographic positionnig. 
l = light('Position',[-0.4 0.2 0.9],'Style','infinite')
material([.9 .3 .3]) %sets the ambient/diffuse/specular strength of the objects.


axis equal off    % make the axes equal and invisible
%axis vis3d off
%axis manual
%p.FaceAlpha = 0.9;   % make the object semi-transparent
%pL.FaceColor = 'interp';    % set the face colors to be interpolated
%p.FaceColor = 'none';    % turn off the colors

%pR.LineStyle = 'none';      % remove the lines

%export_fig(2, '_electrode_coverage_L.png', '-r300', '-transparent');
%close all;


%% count electrodes influencing each vertex

tic
minSubjects = 1;

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
v2p             = 'r' %l or r
crange          = [1 7];%[-.3 .5];
%crange         = [-10 10];
cmp2use         = 'YlOrRd'%'YlOrRd';

gaPow2plot      = eval (dat2plot); %h or t or sumA
gaPatch = gaPow2plot; gaPatch(isnan(gaPow2plot)) = 0;  gaPatch(gaPatch ~= 0) = NaN;
% subj = 13;
% tmean_L = pow2Plot(subj,:);
% tmean_LZP = cat (1, zero2Plot(subj,:),  zero2Plot(subj,:),  zero2Plot(subj,:));

%tmean_L = gaPow2plot';  tmean_LZP = cat (1, gaPatch+.5, gaPatch+.5, gaPatch+.5)';
tmean_L = gaPow2plot';  tmean_LZP = cat (1, gaPatch, gaPatch, gaPatch)';


figure(2);
%cindex = cat(1, tmean, tmean, tmean)';
%cindex = ones(length(g.vertices), 3);
%cindex(t1) = zeros(1,3);
pL = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',tmean_L,'FaceColor','interp'); hold on;
pL.LineStyle = 'none';      % remove the lines


%lighting gouraud; %p.SpecularStrength = 0.4;%camlight

pLZP = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',tmean_LZP,'FaceColor','interp');
pLZP.LineStyle = 'none';      % remove the lines
%pR = patch('Faces',gR.faces,'Vertices',gR.vertices,'FaceVertexCData',tmean_R','FaceColor','interp')

caxis(crange)


colorMap2use = 'hot';
colormap (colorMap2use); %winter works well (also try spring)
colorbar;
if (strcmp (v2p, 'l'))
    view(270,0)     % left orientation
else
	view(90,0)     % right orientation
end
%set(gca, 'CameraViewAngle', 3); %for orthographic positionnig. 
l = light('Position',[-0.4 0.2 0.9],'Style','infinite')
material([.9 .7 .3]) %sets the ambient/diffuse/specular strength of the objects.

set(gca, 'FontSize', 20)

axis equal off    % make the axes equal and invisible
%axis vis3d off
%axis manual
%p.FaceAlpha = 0.9;   % make the object semi-transparent
%pL.FaceColor = 'interp';    % set the face colors to be interpolated
%p.FaceColor = 'none';    % turn off the colors

%pR.LineStyle = 'none';      % remove the lines
x1= pL.FaceVertexCData;
finalColors = vals2colormap(x1, colorMap2use, crange);% NANs are converted to 1
finalColors (isnan(x1),:) = NaN;

%filename = ['_' dat2plot '_' num2str(f(1)) '-' num2str(f(end)) 'Hz.png'];

filename = ['_t_contribution.jpg']
export_fig(2, filename, '-r300', '-transparent');



%%