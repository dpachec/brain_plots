%% Import the FreeSurfer-processed MRI
fsmri_acpc = ft_read_mri([path subjID '/anat/freesurfer/mri/T1.mgz']);
%fsmri_acpc = ft_read_mri([path subjID '/freesurfer/mri/T1.mgz']);
fsmri_acpc.coordsys = 'acpc';




%% Import the anatomical CT
ct = ft_read_mri([path subjID '/anat/' subjID '_CT.nii.gz']);


%%
cfg = []; 
ft_sourceplot(cfg,ct);
cfg = []; 
ft_sourceplot(cfg,fsmri_acpc);

%% determine the native orientation of the anatomical CT’s
ft_determine_coordsys(ct, 'interactive', 'no')
%ft_determine_coordsys(ct, 'interactive', 'yes')


%% Align the anatomical CT to the CTF head surface coordinate system

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc'; % use acpc if not possible with ctf
ct_ctf = ft_volumerealign(cfg, ct);

%% convert the CT’s coordinate system into an approximation of the ACPC coordinate system
%Fuse the CT with the MRI using the below command. ~ aprox 40s
%Write the MRI-fused anatomical CT out to a file 

tic

ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

toc

%% Fuse the CT with the MRI using the below command. ~ aprox 40s

cfg = [];
cfg.method = 'spm';
cfg.spmversion = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);



%% Write the MRI-fused anatomical CT out to a file 
tic 

cfg = [];
cfg.filename = [subjID '_CT_acpc_f'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);

toc