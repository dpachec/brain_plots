# Readme

TheApplication to visualize electrodes and freesurfer average brain with desikan_killiany parcellation scheme
The 3D models in the folder FreeSurfer_Models were extracted using the script extract_obj_from_FS_Parcellation
based on the desikan_killiany parcellation scheme. 
This was  done separately for each region (e.g., "ctx-lh-inferiortemporal")
These files are included in the mniBrain application (to do: allow for flexible grouping into ROIs in the compiled application)

Alternatively, a full brain template (no subdivisions) can be taken from FreeSurfer (Matlab format) using the script extract_obj_from_FS_FullBrain

Note that a path to Freesurfer average surfaces needs to be specificied. This depends on where FreeSurfer is installed- 
Check more info at https://www.fieldtriptoolbox.org/template/atlas/ (FreeSurfer FsAverage section)- 
And https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation


To do: The FreeSurfer atlas in extract_obj_from_FS_FullBrain contains anotations for each vertex (included in the aparc file). This can be use with vertex color to plot the brain. May be a better than obtaining a separate 3D model for each region in the parcellation. 

In FreeSurfer, fsaverage and fsaverage6 are both standard reference templates used for surface-based analyses of the brain, differing primarily in their spatial resolutions:
fsaverage: This is the standard high-resolution template with approximately 163,842 vertices per hemisphere, providing detailed anatomical representation. 
fsaverage6: This is a downsampled version of fsaverage, containing about 40,962 vertices per hemisphere. It offers a balance between anatomical detail and computational efficiency, making it suitable for analyses where reduced processing time is beneficial. 

The plot_brain scritp then goes through all vertices and color codes them according to proximity






