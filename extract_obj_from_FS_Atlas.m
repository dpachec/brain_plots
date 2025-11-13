
%% Script to extract OBJ models from the FreeSurfer average brain based on the desikan_killiany atlas (aparc+aseg.mgz)
%%
clear, clc
%fsPath =  '/Applications/freesurfer/7.3.2/subjects/fsaverage/'; %original freesurfer path when FreeSurfer is installed (MAC)
fsPath =  'fsaverage/'; %minimal version of the same folder included in the repo 
atlas = ft_read_atlas([fsPath 'mri/aparc+aseg.mgz'])
atlas.coordsys = 'mni';
cfg.roi        = {'ctx-lh-inferiortemporal'};
cfg.atlas      = atlas; 
mask_rha        = ft_volumelookup(cfg, atlas);

%%

seg             = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain       = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 1; %smaller values = higher resolution % Check prepare_mesh_segmentation.m a scalar indicating the radius of the target surface mesh element bounding sphere
cfg.maxsurf     = 1;
cfg.numvertices = 100000; %number of vertices needs to be high for fs_average (highest resolution model)
cfg.smooth      = 0;
cfg.spmversion  = 'spm12';
mesh            = ft_prepare_mesh(cfg, seg);


figure()
ft_plot_mesh(mesh,  'facealpha', .5);
title('Average hippocampus + subject MNI');


mesh2export = surfaceMesh(mesh.pos,mesh.tri);


%% 

writeSurfaceMesh(mesh2export, 'myM.obj')

