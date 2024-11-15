%%
%% First establish the main path

clear
mainPath = 'D:/Appartment/extract_electrodes/';

%% create empty folders for N number of subjects

numSubj = 27; 

for subji = 1:numSubj
    
    string_path = [mainPath 's' num2str(subji, '%02d')]; 
    mkdir(string_path);

end

%% each folder needs to contain 
% 1) MRI in ACPC coordinates (s01_T1_acpc.nii), generated in 3D slicer
% 2) Raw post CT scan (s01_CT.nii.gz)


%%
subjID = 's01';
cd ([mainPath subjID]);


%% convert fiducias in acpc space to MNI using the affine transform
% read xfm of this particular subject
xfm = read_talxfm([mainPath subjID '/talairach.xfm'])


%% read fiducials
fiducials = readtable('s01_fid_acpc.csv'); 
elec_acpc = table2array(fiducials(:, 2:4))

%% apply transform

elec_mni= apply_transformation(elec_acpc, xfm); 

%% create struct for fieldtrip

clear elec_mni_frv
elec_mni_frv.chanpos = elec_mni; 
elec_mni_frv.label = fiducials.Label; 
elec_mni_frv.unit = 'mm'; 



%% Visualize the cortical mesh extracted from the standard MNI brain along with the spatially normalized electrode
load('D:/Documents/MATLAB/fieldtrip-master/template/anatomy/surface_pial_left.mat');
figure
ft_plot_mesh(mesh, 'facealpha', .5); 
ft_plot_sens(elec_mni_frv, 'elecsize', 100, 'facecolor', [1 0 0]);
%ft_plot_sens(elec_acpc_f, 'elecsize', 100);
view([-55 10]);
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
pial_lh = ft_read_headshape([mainPath subjID '/freesurfer/surf/lh.pial.T1']);
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh, 'facealpha', .5); 
ft_plot_sens(elec_acpc_frv, 'elecsize', 100, 'facecolor', [1 0 0]);
%ft_plot_sens(elec_acpc_f, 'elecsize', 100);
view([-55 10]);
material dull; 
lighting gouraud; 
camlight;