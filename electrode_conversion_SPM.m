%% First establish the main path

clear, clc
mainPath = 'D:/Appartment/extract_electrodes/';

%%
subjID = 's21';


%% read fiducials and create struct for fieldtrip
fiducials = readtable([mainPath subjID '/' subjID '_fiducials.csv']); 
elec_acpc = table2array(fiducials(:, 2:4));
clear elec_mni_frv
elec_acpc_f.chanpos = elec_acpc; 
elec_acpc_f.elecpos = elec_acpc; 
elec_acpc_f.label = fiducials.Label; 
elec_acpc_f.unit = 'mm'; 

%% read MRI in acpc
fsmri_acpc = ft_read_mri([mainPath subjID '/freesurfer/mri/T1.mgz']);
fsmri_acpc.coordsys = 'acpc';

%% Register the subject’s brain to the standard MNI brain ~aprox 1:30min
tic

cfg = [];
cfg.nonlinear = 'yes';
cfg.spmversion = 'spm12';
cfg.spmmethod  = 'new';
fsmri_mni = ft_volumenormalise(cfg, fsmri_acpc);

toc

%% Use the resulting deformation parameters to obtain the electrode positions in standard MNI space
% aprox 20s

tic
elec_mni_frv = elec_acpc_f;
elec_mni_frv.elecpos = ft_warp_apply(fsmri_mni.params, elec_acpc_f.elecpos, 'individual2sn');
elec_mni_frv.chanpos = elec_mni_frv.elecpos;
elec_mni_frv.coordsys = 'mni';
toc

%% Visualize the cortical mesh extracted from the standard MNI brain along with the spatially normalized electrode
load('D:/Documents/MATLAB/fieldtrip-master/template/anatomy/surface_pial_left.mat');
figure
ft_plot_mesh(mesh, 'facealpha', .5); 
ft_plot_sens(elec_mni_frv, 'elecsize', 20, 'facecolor', [1 0 0]);
view([-10 10]);
material dull; 
lighting gouraud; 
camlight;

%% save normalized electrode to file

save([subjID '_elec_mni_frv.mat'], 'elec_mni_frv');
disp('done')

%% plot average + mni electrodes
tic

atlas = ft_read_atlas([path 'average_MNI_brain/fsaverage6/mri/aseg.mgz']);
atlas.coordsys = 'mni';
cfg            = [];
cfg.inputcoord = 'mni';
cfg.atlas      = atlas;
%cfg.roi        = {'Left-Cerebral-Cortex'};
cfg.roi        = {'Left-Hippocampus'};
mask_rha = ft_volumelookup(cfg, atlas);

seg             = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain       = mask_rha;
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

atlas = ft_read_atlas([path subjID '/freesurfer/mri/aparc+aseg.mgz']);
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = {'Right-Hippocampus'};
mask_rha     = ft_volumelookup(cfg, atlas);

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
mesh_rha_subject = ft_prepare_mesh(cfg, seg);

toc

%% final figure

figure(1)
ft_plot_mesh(mesh_rha_average,  'facealpha', .5);
ft_plot_sens(elec_mni_frv);
title('Average hippocampus + subject MNI');

%%
figure(2)
ft_plot_mesh(mesh_rha_subject,  'facealpha', .5);
ft_plot_sens(elec_acpc_f);
title('Subject specific hippocampus');



%%

[vertices faces] = readObj('left_hippocampus.obj');

pL = patch('Faces',faces,'Vertices',vertices); hold on;
pL.LineStyle = 'none';      % remove the lines
l = light('Position',[-0.4 0.2 0.9],'Style','infinite')
material([.9 .7 .3]) %sets the ambient/diffuse/specular strength of the objects.
view(90,0)

%%
%cd 'D:\owncube\miniXIM\_WM\WM_datasets\china\WM01_m_20190826_hangzhou\caidabao_preMR'
projectdir = 'D:\owncube\miniXIM\_WM\WM_datasets\china\WM01_m_20190826_hangzhou\caidabao_preMR';
dicomFiles = dir( fullfile(projectdir, '*.dcm' ));
files = {dicomFiles.name};
y = length(dicomFiles)
X = zeros(512, 512, 1, y, 'uint8');
% Read the series of images.
for p=1:y
   filename = fullfile( projectdir, dicomFiles(p).name );
   X(:,:,1,p) = dicomread(filename);
end
% Display the image stack.
montage(X,[])


%%
projectdir = 'D:\owncube\miniXIM\_WM\WM_datasets\china\WM01_m_20190826_hangzhou\caidabao_preMR';
dicomFiles = dir( fullfile(projectdir, '*.dcm' ));
files = {dicomFiles.name};




dicom2nifti(files)



%% get all labels again

subjID = 'ASJ';
path = '/Users/danielpacheco/Desktop/agency_mni_electrodes/';
%%

atlas = ft_read_atlas([path subjID '/freesurfer/mri/aparc+aseg.mgz']);
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = {'Right-Hippocampus'};
mask_rha     = ft_volumelookup(cfg, atlas);















