%Script for Plotting Bactericidal Assays

%Enter the specific path for the .csv file with your data. 
path_data = '/Users/sophieengels/desktop/Bactericidal Assay Data - ButT6 0.75 Averaged copy.csv';

%Plotting table data will only work with MATLAB 2021 version or later. 
assay_data = readtable(path_data);
E_data = assay_data(1:4,:);
R_data = assay_data(5:8,:);
Z_data = assay_data(9:12,:);

avg1 = loglog(E_data.DrugConcentration,E_data.AverageCFU_mL,'.','MarkerSize',20,'Color',[0.9290 0.6940 0.1250]);
hold on
avg2 = loglog(R_data.DrugConcentration,R_data.AverageCFU_mL,'.','MarkerSize',20,'Color','red');
avg3 = loglog(Z_data.DrugConcentration,Z_data.AverageCFU_mL,'.','MarkerSize',20,'Color','blue');

legend('EMB','RIF','PZA', 'FontSize',18,'Location','bestoutside')
xlabel('Drug Concentration (ug/mL)','FontSize',18)
ylabel('CFU/mL','FontSize',18)

%Change the title for your specific data. 
title('ButT6 Bactericidal Assay - Corrected','FontSize',18)
