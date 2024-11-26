%% 
%% First align all subjects CT scans to CTF and then ACPC (this has to be done for all subjects before running the SPM loop below)
clear, clc 
globalPath = 'D:/Appartment/extract_electrodes/'; 

subjID = 's01';

%Import the anatomical CT
ct = ft_read_mri([globalPath subjID '/' subjID '_CT.nii.gz']);
%determine the native orientation of the anatomical CT’s > this is not necessary, all left 2 right
% ft_determine_coordsys(ct, 'interactive', 'no') 
% plot just to check
%cfg = []; 
%ft_sourceplot(cfg,ct);
%cfg = []; 
%ft_sourceplot(cfg,fsmri_acpc);


%% Align the anatomical CT to the CTF head surface coordinate system > normally this should be done, so no loop, let's test without
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf'; % use acpc if not possible with ctf
ct_ctf = ft_volumerealign(cfg, ct);

%% Convert CTF to ACPC and write the anatomical CT in ACPC coordinates out to a file 

ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');
cfg = [];
cfg.filename = [globalPath subjID '/' subjID '_CT_acpc'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc);


%% loop to corregister CTs and MR scans using SPM
clear, clc

globalPath = 'D:/Appartment/extract_electrodes/'; 
%subjID = 's02'; 


for subji = 1% [1:8 10:27] %subject 9 has 3 DICOM batches and is done in 3DSlicer

    subjID = ['s' num2str(subji, '%02d')]; 

    %Import the FreeSurfer-processed MRI
    fsmri_acpc = ft_read_mri([globalPath subjID '/freesurfer/mri/T1.mgz']);
    fsmri_acpc.coordsys = 'acpc';

    %Import the CT in ACPC coordinates
    ct_acpc = ft_read_mri([globalPath subjID '/' subjID '_CT_acpc.nii']);

    
    %%Fuse the CT with the MRI using the below command. ~ aprox 40s
    
    cfg = [];
    cfg.method = 'spm';
    cfg.spmversion = 'spm12';
    cfg.coordsys = 'acpc';
    cfg.viewresult = 'yes';
    ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
    
    
    
    %%Write the MRI-fused anatomical CT out to a file 
    tic 
    
    cfg = [];
    cfg.filename = [globalPath subjID '/' subjID '_CT_acpc_f'];
    cfg.filetype = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, ct_acpc_f);
    
    toc

    


end




%%