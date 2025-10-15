%% Extract labels from the individual brains, convert acpc coordinates to mni and export table 
%% First establish main path

clear, clc
%mainPath = 'D:/Appartment/extract_electrodes/';
mainPath = '/Users/danielpacheco/Documents/iEEG_projects/Appartment/electrode_information/';
%mainPath = 'C:/Users/1764316/Desktop/electrode_location_remaining_subjects/'; 


for subji = 35:35

    subjID = ['s' num2str(subji, '%02d')];
    elecCSV = readtable([mainPath subjID '/' subjID '_fiducials.csv']);
    elec.chanpos = table2array(elecCSV(:, 2:4));
    elec.label = table2cell(elecCSV(:, 1))
    
    tic
    atlas = ft_read_atlas([mainPath subjID '/freesurfer/mri/aparc+aseg.mgz']); %subject specific Desikan Killiany
    %atlas = ft_read_atlas([mainPath subjID '/freesurfer/mri/aparc.a2009s+aseg.mgz']); %subject specific Destrieux
    atlas.coordsys = 'acpc';
    
    cfg            = [];
    cfg.inputcoord = 'acpc';
    cfg.atlas      = atlas;
    cfg.roi        = elec.chanpos;
    cfg.minqueryrange = 5;
    cfg.maxqueryrange = 5;
    cfg.output        = 'multiple'; % since v2
    labels         = ft_volumelookup(cfg, atlas);


    xfm = read_talxfm([mainPath subjID '/freesurfer/mri/transforms/talairach.xfm'])
    elec_mni = apply_transformation(elec.chanpos, xfm); 
    
    clear table 
    for e = 1:numel(elec.label) % electrode loop
        table{e,1} = elec.label{e}; % Electrode
        table{e,2} = num2str(elec_mni(e,1)); % Coordinates
        table{e,3} = num2str(elec_mni(e,2)); % Coordinates
        table{e,4} = num2str(elec_mni(e,3)); % Coordinates
        [cnt, idx] = max(labels(e).count);
        lab  = char(labels(e).name(idx)); % anatomical label
        table{e,5} = lab; 
    end 
    
    
    writecell(table, [mainPath subjID '/' subjID '_elec_mni_labels.csv']);
    
    

end





%% First establish the main path
%%
clear, clc

%mainPath = 'D:/Appartment/extract_electrodes/';
mainPath = '/Users/danielpacheco/Documents/iEEG_projects/Appartment/electrode_information/';


%%

subjID = 's29';
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
    %table{e,2} = num2str(elec.chanpos(e,:)); % Coordinates
    table{e,2} = num2str(elec.chanpos(e,1)); % Coordinates
    table{e,3} = num2str(elec.chanpos(e,2)); % Coordinates
    table{e,4} = num2str(elec.chanpos(e,3)); % Coordinates
    
    % enter anatomical labels and lookup stats
    [cnt, idx] = max(labels(e).count);
    lab  = char(labels(e).name(idx)); % anatomical label
    %table{e,3} = lab; 
    table{e,5} = lab; 
    
end % end of electrode loop

toc








%%