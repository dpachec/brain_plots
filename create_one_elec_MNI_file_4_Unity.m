%%

%%


clear, clc
mainPath = 'D:/Appartment/extract_electrodes/';

allElec = []; 
for subji = 1:27

    subjID = ['s' num2str(subji, '%02d')];
    elecCSV = readtable([mainPath subjID '/' subjID '_elec_mni_labels.csv']);
    elecCSV(:, 6) = {subji}; 

    allElec = [allElec ; elecCSV]



end

writetable(allElec, [mainPath 'all_elec_mni.csv']);



%%