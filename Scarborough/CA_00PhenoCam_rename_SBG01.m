flag_unix=0;
if flag_unix==1
    FolderName='C:\Users\ncoupe\Documents\Canada\Toronto\Bushnell\';
    slash='/';
else
    FolderName='/media/ncoupe/Expansion/Data/Canada/Toronto/Phenocam/Scarborough/2026/';
    addpath /home/ncoupe/Documents/OZ
    addpath /home/ncoupe/Documents/Amazon
    slash='/';
end

OZ_phenocam_rename([FolderName 'SBG_oblique_02*.JPG'],'SBG_oblique_01','unix','Wingscapes',0)
