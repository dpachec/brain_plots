%%
%% load fieldtrip template 
clear, clc 
load ('D:\Documents\MATLAB\fieldtrip-master\template\anatomy\surface_pial_both.mat') % load freesurfer template. In stolk et al, this is indicated as the MNI freesurfer template (Figure 4, step 28)

mesh2.vertices = mesh.pos;
mesh2.faces = mesh.tri;


%% 

obj_write(mesh2, 'myObj')
