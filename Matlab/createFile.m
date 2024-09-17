function meas_results_txt = createFile(folder_path, measurement_index)

% create a txt file
filename = sprintf('Meas%sResults.txt', measurement_index);
full_path = fullfile (folder_path, filename);
meas_results_txt = fopen(full_path, 'w');
fprintf(meas_results_txt,'Tap\tI_c\t\tn\t\tRsquare\n');