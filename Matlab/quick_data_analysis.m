clearvars
beep off
tic

%% point to a specific set of measurements
folder_path = 'C:\Users\39329\Documents\Tesi LASA\Experiments Data\Piccole_bobine_C1\20240314'
meas_index = 4;
plot_check_bool = 1

%% constants of the specific problem
% choose the constants of the set 
dI_for_plateau = 1;
turns = 31;
current_for_inductance = 10; % ampere
total_energy = 0.00436533; %joules
inductance = 2*total_energy/(current_for_inductance^2); % Henry

measurement_index = sprintf('0%i', meas_index);
    
%% extract data
file_pattern = sprintf('Meas*%s.tdms', measurement_index);
files = dir(fullfile(folder_path, file_pattern))
if isempty(files)
    error('No file found');
end
dataname = fullfile(folder_path, files(1).name);
Data{1} = tdmsread(dataname);
Time_1 = table2array(Data{1}{1,1}(:,1));
Time_2 = table2array(Data{1}{1,1}(:,2)) - table2array(Data{1}{1,1}(1,2));
Hall_mV = 1e3*table2array(Data{1}{1,1}(:,3));
SC_mV = 1e3*table2array(Data{1}{1,1}(:,5));
I_supply = 1e3*table2array(Data{1}{1,1}(:,4));
J1_mV = 1e3*table2array(Data{1}{1,1}(:,6));
J2_mV = 1e3*table2array(Data{1}{1,1}(:,10)); 
T10_mV = 1e3*table2array(Data{1}{1,1}(:,7));
T15_20_mV = 1e3*table2array(Data{1}{1,1}(:,8));
T31_mV = 1e3*table2array(Data{1}{1,1}(:,9));

%% unit conversion
I_supply=I_supply*2/5
if measurement_index >= 3
    gain = 100;
    Hall_mV = Hall_mV / gain;
end

figure(1)
set(gcf,'Color','k');  % Set background color to black
ax = gca;  % Get current axes
ax.Color = 'k';  % Set background color to black
hold on
yyaxis left;
plot (I_supply, 'w');
yyaxis right;
plot (SC_mV,'b');
plot (T10_mV, 'g');
plot (T15_20_mV,'r');
plot (T31_mV,'y');
plot (J1_mV,'c');
plot (J2_mV, 'm');
% Change legend text color to white
legend('I\_supply', 'SC\_mV', 'T10\_mV', 'T15\_20\_mV', 'T31\_mV', 'J1\_mV', 'J2\_mV');
hLegend = findobj(gcf, 'Type', 'Legend');
set(hLegend, 'TextColor', 'w');
grid on
hold off

figure(2)
set(gcf,'Color','k');  % Set background color to black
ax = gca;  % Get current axes
ax.Color = 'k';  % Set background color to black
hold on
grid on
plot (J1_mV, 'w', 'DisplayName', 'J1\_mV');
plot (T10_mV, 'b', 'DisplayName', 'T10\_mV');
plot (T15_20_mV, 'g', 'DisplayName', 'T15\_20\_mV');
% Change legend text color to white
legend('TextColor', 'w');
hLegend = findobj(gcf, 'Type', 'Legend');
set(hLegend, 'TextColor', 'w');

figure(3)
set(gcf,'Color','k');  % Set background color to black
ax = gca;  % Get current axes
ax.Color = 'k';  % Set background color to black
hold on
grid on
plot (I_supply,J1_mV, '.w', 'DisplayName', 'J1\_mV');
plot (I_supply,T10_mV, '.b', 'DisplayName', 'T10\_mV');
plot (I_supply,T15_20_mV, '.g', 'DisplayName', 'T15\_20\_mV');
% Change legend text color to white
legend('TextColor', 'w');
hLegend = findobj(gcf, 'Type', 'Legend');
set(hLegend, 'TextColor', 'w');

figure(4)
set(gcf,'Color','k');  % Set background color to black
ax = gca;  % Get current axes
ax.Color = 'k';  % Set background color to black
hold on
grid on
plot (SC_mV-T31_mV, '.w', 'DisplayName', 'diff');
plot (T10_mV+T15_20_mV, '.b', 'DisplayName', 'sum');
% Change legend text color to white
legend('TextColor', 'w');
hLegend = findobj(gcf, 'Type', 'Legend');
set(hLegend, 'TextColor', 'w');


toc