
%% Script to extract OBJ models from the FreeSurfer average brain based on the desikan_killiany parcellation (aparc+aseg.mgz)
%%
clear, clc
%fsPath =  '/Applications/freesurfer/7.3.2/subjects/fsaverage/'; %original freesurfer path when FreeSurfer is installed (MAC)
fsPath =  'fsaverage/'; %minimal version of the same folder included in the repo 
atlas = ft_read_atlas([fsPath 'mri/aparc+aseg.mgz'])
atlas.coordsys = 'mni';
cfg.roi        = {'ctx-lh-inferiortemporal'};
cfg.atlas      = atlas; 
mask_rha        = ft_volumelookup(cfg, atlas);



seg             = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain       = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 50000; %number of vertices needs to be high for fs_average (highest resolution model)
cfg.smooth      = 2;
cfg.spmversion  = 'spm12';
mesh_rha_average = ft_prepare_mesh(cfg, seg);


figure()
ft_plot_mesh(mesh_rha_average,  'facealpha', .5);
title('Average hippocampus + subject MNI');




%%