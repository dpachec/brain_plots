%%
%% First establish the main path

clear
%mainPath = 'D:/Appartment/extract_electrodes/';
mainPath = '/Users/danielpacheco/Documents/iEEG_projects/Appartment/electrode_information/';

%%
subjID = 's03';


%% convert fiducias in acpc space to MNI using the affine transform
% read xfm of this particular subject
xfm = read_talxfm([mainPath subjID '/freesurfer/mri/transforms/talairach.xfm'])


%% read fiducials
fiducials = readtable([mainPath subjID '/' subjID '_fiducials.csv']); 
elec_acpc = table2array(fiducials(:, 2:4));

%% apply transform

elec_mni= apply_transformation(elec_acpc, xfm); 

%% create struct for fieldtrip

clear elec_mni_frv
elec_mni_frv.chanpos = elec_mni; 
elec_mni_frv.label = fiducials.Label; 
elec_mni_frv.unit = 'mm'; 



%% Visualize the cortical mesh extracted from the standard MNI brain along with the spatially normalized electrode
%load('D:/Documents/MATLAB/fieldtrip-master/template/anatomy/surface_pial_left.mat');
load('/Users/danielpacheco/Documents/MATLAB/fieldtrip-master/template/anatomy/surface_pial_left.mat');
figure
ft_plot_mesh(mesh, 'facealpha', .5); 
ft_plot_sens(elec_mni_frv, 'elecsize', 20, 'facecolor', [1 0 0]);
%ft_plot_sens(elec_acpc_f, 'elecsize', 100);
view([-10 10]);
material dull; 
lighting gouraud; 
camlight;


%% create struct for fieldtrip with acpc electrods

clear elec_acpc_frv
elec_acpc_frv.chanpos = elec_acpc; 
elec_acpc_frv.label = fiducials.Label; 
elec_acpc_frv.unit = 'mm'; 



%% Visualize the cortical mesh of an individual subject 
%%and examine their quality.
figure
pial_lh = ft_read_headshape([mainPath subjID '/freesurfer/surf/lh.pial.T1']);
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh, 'facealpha', .5); 
ft_plot_sens(elec_acpc_frv, 'elecsize', 20, 'facecolor', [1 0 0]);
%ft_plot_sens(elec_acpc_f, 'elecsize', 100);
view([-10 10]);
material dull; 
lighting gouraud; 
camlight;


%% plot average + mni electrodes
tic

atlas = ft_read_atlas('/Users/danielpacheco/Documents/Github/brain_plots/fsaverage/mri/aparc+aseg.mgz');
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = {'Right-Hippocampus'};
mask_rha = ft_volumelookup(cfg, atlas);

seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha_average = ft_prepare_mesh(cfg, seg);

%% plot subject specific 2 compare

atlas = ft_read_atlas([mainPath subjID '/freesurfer/mri/aparc+aseg.mgz']);
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = {'ctx-lh-precuneus'}; 
%mask_rha     = ft_volumelookup(cfg, atlas);
%cfg.roi        = {'Left-Hippocampus'};
mask_rha      = ft_volumelookup(cfg, atlas);

seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain       = mask_rha1;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 10000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha_subject = ft_prepare_mesh(cfg, seg);

toc

%% final figure

figure(1)
ft_plot_mesh(mesh_rha_average,  'facealpha', .5);
ft_plot_sens(elec_mni_frv);
title('Average hippocampus + subject MNI');
%%
figure(2)
%ft_plot_mesh(mesh_rha_subject,  'facealpha', .5);
ft_plot_mesh(mesh_rha_subject,  'facealpha', .5, 'facecolor', 'none', 'edgecolor', 'k');
ft_plot_sens(elec_acpc_frv, 'label', 'on');
title('Subject specific hippocampus');

%%
figure(1)
ft_plot_mesh(mesh_rha_average,  'facealpha', .5); hold on; 
ft_plot_mesh(mesh_rha_subject,  'facealpha', .5);
