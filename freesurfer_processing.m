%%
clear
mainPath = '/Users/danielpacheco/Desktop/extract_electrodes/'; 

%% MAIN LOOP 


fshome = '/Applications/freesurfer/7.3.2';
for subji = [2:12 14:27]
    
    subdir = [mainPath 's' num2str(subji, '%02d')];
    subjID = ['s' num2str(subji, '%02d')];
    mrfile = [subdir '/' subjID '_MR_acpc.nii'];
    
    system(['export FREESURFER_HOME=' fshome '; ' ...
            'source $FREESURFER_HOME/SetUpFreeSurfer.sh; ' ...
            'mri_convert -c -oc 0 0 0 ' mrfile ' ' [subdir '/tmp.nii'] '; ' ...
            'recon-all -i ' [subdir '/tmp.nii'] ' -s ' 'freesurfer' ' -sd ' subdir ' -all']);


    
end




%% Cortical surface extraction with FreeSurfer
tic
subjID = 's01'
fshome = '/Applications/freesurfer/7.3.2';
subdir = ['/Users/danielpacheco/Desktop/extract_electrodes/' subjID '/anat'];
mrfile = ['/Users/danielpacheco/Desktop/extract_electrodes/' subjID '/anat/' subjID '_MR_acpc.nii'];
system(['export FREESURFER_HOME=' fshome '; ' ...
'source $FREESURFER_HOME/SetUpFreeSurfer.sh; ' ...
'mri_convert -c -oc 0 0 0 ' mrfile ' ' [subdir '/tmp.nii'] '; ' ...
'recon-all -i ' [subdir '/tmp.nii'] ' -s ' 'freesurfer' ' -sd ' subdir ' -all']);
toc



%% Import the extracted cortical surfaces into the MATLAB workspace 
%%and examine their quality.

pial_lh = ft_read_headshape([path subjID '/anat/freesurfer/surf/lh.pial']);
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
lighting gouraud;
camlight;