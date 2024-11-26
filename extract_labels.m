%% First establish the main path
%%
clear, clc


mainPath = 'D:/Appartment/extract_electrodes/';


%%

subjID = 's01';
elecCSV = readtable([mainPath subjID '/' subjID '_fiducials.csv']);
elec.chanpos = table2array(elecCSV(:, 2:4));
elec.label = table2cell(elecCSV(:, 1))


%% plot subject specific 2 compare

tic
atlas = ft_read_atlas([mainPath subjID '/freesurfer/mri/aparc+aseg.mgz']); %subject specific Desikan Killiany
%atlas = ft_read_atlas([mainPath subjID '/freesurfer/mri/aparc.a2009s+aseg.mgz']); %subject specific Destrieux
atlas.coordsys = 'acpc';

%%
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = elec.chanpos;
cfg.minqueryrange = 5;
cfg.maxqueryrange = 5;
cfg.output        = 'multiple'; % since v2
labels         = ft_volumelookup(cfg, atlas);

toc

%%
clear table 
tic

for e = 1:numel(elec.label) % electrode loop

    % enter electrode information
    table{e,1} = elec.label{e}; % Electrode
    table{e,2} = num2str(elec.chanpos(e,:)); % Coordinates
    
    % enter anatomical labels and lookup stats
    [cnt, idx] = max(labels(e).count);
    lab  = char(labels(e).name(idx)); % anatomical label
    table{e,3} = lab; % no_label_found
    
end % end of electrode loop

toc






%%



