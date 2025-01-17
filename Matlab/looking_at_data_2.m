clearvars
close all
beep off
tic

%% point to a specific set of measurements
% choose the index of measurement and the folder where the set of
% measurements is stored. if only one set needs to be displayed choose the same index for both starting and ending measurements.
% set ramp_bool = 1 if the current is a ramp
% set plot_check_bool = 1 if check plots are needed
% set plot_bool = 1 if results plot are needed

coil_id = 2;
dataset = 20240314;
starting_measurement = 2;
ending_measurement = starting_measurement;
plot_check_bool = 1;
plot_bool = 1;
cut_question = 1;
cut_bool = 1;
initial_index = 1;
final_index = 138000;

folder_path = sprintf('C:\\Users\\39329\\Documents\\Tesi LASA\\Experiments Data\\Piccole_bobine_C%i\\%i\\RawData', coil_id, dataset);


%% constants of the specific problem
% choose the constants of the set 
dI_for_plateau = 1;
turns = 31;
current_for_inductance = 10; % ampere
total_energy = 0.00436533; %joules
% total_energy = 9.47245
inductance = 2*total_energy/(current_for_inductance^2); % Henry

for j=starting_measurement:ending_measurement
    measurement_index = sprintf('0%i', j);
    
    %% extract data
    file_pattern = sprintf('Meas*%s.tdms', measurement_index);
    files = dir(fullfile(folder_path, file_pattern))
    if isempty(files)
        error('No file found');
    end
    dataname = fullfile(folder_path, files(1).name);

    plots_folder_name = sprintf('Plots_Meas_%s', measurement_index);  % Create a valid folder name
    
    % Create the full path for the plots folder
    plots_folder_path = fullfile(folder_path, plots_folder_name);  
    
    % Check if the directory exists, if not, create it
    if ~exist(plots_folder_path, 'dir')
        mkdir(plots_folder_path);  % Create folder if it doesn't exist
    end

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
    Shunt_factor = 250/60;
    I_supply = I_supply * Shunt_factor;
    if measurement_index >= 3
        gain = 100;
        Hall_mV = Hall_mV / gain;
    end
    
    %% Discard data which are taken more than 1 time
    % Eliminate repeated measurements. nonrep_measurements_logic is a logical array where 1
    % signifies that two consecutive measurements do not have the same value, and thus
    % are not repeated measurements of the same value. I_supply_nonrep_filtered contains the
    % measurements of I_supply taken only once.
    nonrep_measurements_logic = [0; diff(I_supply)] ~= 0;
    I_supply_nonrep = I_supply(nonrep_measurements_logic);
    SC_mV_nonrep = SC_mV(nonrep_measurements_logic);
    Hall_mV_nonrep = Hall_mV(nonrep_measurements_logic);
    J1_mV_nonrep = J1_mV(nonrep_measurements_logic);
    J2_mV_nonrep = J2_mV(nonrep_measurements_logic);
    T10_mV_nonrep = T10_mV(nonrep_measurements_logic);
    T15_20_mV_nonrep = T15_20_mV(nonrep_measurements_logic);
    T31_mV_nonrep = T31_mV(nonrep_measurements_logic);
    Time_1_nonrep = Time_1(nonrep_measurements_logic);

    figure(600)
    plot(I_supply_nonrep)
    figure(601)
    plot(SC_mV_nonrep)

    %% ask the user if they want to cut the data
    if cut_question == 1
        blue_monster = input('Do you see a blue monster? type 1 for yes and 0 for no: ')
    end
    if cut_question == 1
        ramp_bool = input('Is this a ramp? type 1 for yes and 0 for no: ')
    end
    if cut_question == 1
        cut_bool = input('Do you want to cut the data? type 1 for yes and 0 for no: ')
    end

    if cut_bool==1
        initial_index = input('Initial index: ')
        final_index = input('Final index: ')
    end
    
    %% cut above I_cut
    if cut_bool==1
        I_supply_nonrep = I_supply(initial_index:final_index);
        SC_mV_nonrep = SC_mV_nonrep(initial_index:final_index);
        Hall_mV_nonrep = Hall_mV_nonrep(initial_index:final_index);
        J1_mV_nonrep = J1_mV_nonrep(initial_index:final_index);
        J2_mV_nonrep = J2_mV_nonrep(initial_index:final_index);
        T10_mV_nonrep = T10_mV_nonrep(initial_index:final_index);
        T15_20_mV_nonrep = T15_20_mV_nonrep(initial_index:final_index);
        T31_mV_nonrep = T31_mV_nonrep(initial_index:final_index);
        Time_1_nonrep = Time_1_nonrep(initial_index:final_index);
    end

    figure(602)
    plot(I_supply_nonrep)
    figure(603)
    plot(SC_mV_nonrep)
    
     %% remove zeros
    if blue_monster==1
        I_zeros = find(I_supply_nonrep == 0);
        I_supply_nonrep(I_zeros)=[];
        SC_mV_nonrep(I_zeros) = [];
        Hall_mV_nonrep(I_zeros) = [];
        J1_mV_nonrep(I_zeros) = [];
        J2_mV_nonrep(I_zeros) = [];
        T10_mV_nonrep(I_zeros) = [];
        T15_20_mV_nonrep(I_zeros) =[];
        T31_mV_nonrep(I_zeros) = [];
        Time_1_nonrep(I_zeros) = [];

        I_over = find (I_supply_nonrep > 70)
        I_supply_nonrep(I_over)=[];
        SC_mV_nonrep(I_over) = [];
        Hall_mV_nonrep(I_over) = [];
        J1_mV_nonrep(I_over) = [];
        J2_mV_nonrep(I_over) = [];
        T10_mV_nonrep(I_over) = [];
        T15_20_mV_nonrep(I_over) =[];
        T31_mV_nonrep(I_over) = [];
        Time_1_nonrep(I_over) = [];
    end


    % create a vector of indices
    indices_nonrep_vector = linspace(1,numel(I_supply_nonrep), numel(I_supply_nonrep));

    figure(601)
    plot(I_supply_nonrep)

    %% filter data
    filter_order = 1;
    hpf = 0.05;
    design_method = 'butter';
    filter =  designfilt('lowpassiir', 'FilterOrder', filter_order, 'HalfPowerFrequency', hpf, 'DesignMethod', design_method);
    I_supply_nonrep_filtered=filtfilt(filter, I_supply_nonrep);

    if ramp_bool == 0
        %% Plateau identification
        % identify plateaus and remove any other measurement except plateaus. this
        % filter is applied twice to ensure a power filtering
         % I_supply_nonrep_filtered = I_supply_nonrep;
         SC_mV_nonrep_filtered = SC_mV_nonrep;
         Hall_mV_nonrep_filtered = Hall_mV_nonrep;
         J1_mV_nonrep_filtered = J1_mV_nonrep;
         J2_mV_nonrep_filtered = J2_mV_nonrep;
         T10_mV_nonrep_filtered = T10_mV_nonrep;
         T15_20_mV_nonrep_filtered = T15_20_mV_nonrep;
         T31_mV_nonrep_filtered = T31_mV_nonrep;
         Time_1_nonrep_filtered = Time_1_nonrep;
         indices_nonrep_vector_filtered = indices_nonrep_vector;
        
        for a = 1:2
            dI_ref = 0.01;
            % dI_ref = 14;
            dI = [0; diff(I_supply_nonrep_filtered(:))];
            plateau_bool = abs(dI) < dI_ref;
            I_supply_nonrep_filtered = I_supply_nonrep_filtered(plateau_bool);
            SC_mV_nonrep_filtered = SC_mV_nonrep_filtered(plateau_bool);
            Hall_mV_nonrep_filtered = Hall_mV_nonrep_filtered(plateau_bool);
            J1_mV_nonrep_filtered = J1_mV_nonrep_filtered(plateau_bool);
            J2_mV_nonrep_filtered = J2_mV_nonrep_filtered(plateau_bool);
            T10_mV_nonrep_filtered = T10_mV_nonrep_filtered(plateau_bool);
            T15_20_mV_nonrep_filtered = T15_20_mV_nonrep_filtered(plateau_bool);
            T31_mV_nonrep_filtered = T31_mV_nonrep_filtered(plateau_bool);
            indices_nonrep_vector_filtered = indices_nonrep_vector_filtered(plateau_bool);
            Time_1_nonrep_filtered = Time_1_nonrep_filtered(plateau_bool);
        end

        

        % Identifica i cambiamenti nel vettore I_supply_nonrep_filtered per trovare inizio e fine di ciascun plateau
        % plateaus_first_indices è un vettore composto dagli indici di
        % I_supply_nonrep_filtered per cui si ha un cambiamento di plateau
        dI_supply_nonrep_filtered = [0; diff(I_supply_nonrep_filtered)];
        plateaus_first_indices = [1; find(abs(dI_supply_nonrep_filtered) > dI_for_plateau); numel(I_supply_nonrep_filtered)];
        abs_plateaus_first_indices = indices_nonrep_vector_filtered(plateaus_first_indices);
        
        for i=1:numel(plateaus_first_indices)
            plateau_starting_value(i) = I_supply_nonrep_filtered(plateaus_first_indices(i));
        end
        
        %% control plots
        if plot_check_bool == 1
            figure (1)
            hold on
            title('check of plateau filter selection and plateau first point selection')
            plot(indices_nonrep_vector, I_supply_nonrep, '.-');
            plot(indices_nonrep_vector_filtered, I_supply_nonrep_filtered,  'ro', LineWidth=0.8);
            plot(abs_plateaus_first_indices, plateau_starting_value, 'gx', LineWidth=3.5)
            legend ('non repeated I supply measurements','filtered non repeated measurements of I supply','plateau starting point')
            ylabel('Current')
            xlabel('index')
            grid on
        end
        
        %% inizializzazione variabili
        % Creazione di una cella per archiviare i vettori plateau. le celle sono
        % usate per memorizzare più vettori di lunghezze diverse. plateau_cell, è
        % una cella di una riga e un numero di colonne pari a alla lunghezza del
        % vettore plateaus_first_indices. Ogni colonna di questa cella sarà
        % usata per memorizzare un vettore relativo ad un plateau.
        plateau_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_SC_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_Hall_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_J1_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_J2_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_T10_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_T15_20_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_T31_cell = cell(1, numel(plateaus_first_indices) - 1);
        plateau_Time1_cell = cell(1, numel(plateaus_first_indices) - 1);
        
        % Creazione di celle per archiviare i vettori transitori.
        transient_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_SC_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_Hall_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_J1_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_J2_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_T10_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_T15_20_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_T31_cell = cell(1, numel(plateaus_first_indices) - 1);
        transient_Time1_cell = cell(1, numel(plateaus_first_indices) - 1);
        
        % Inizializzazione celle
        % Creazione cella per archiviare le medie dei valori dei plateau
        plateau_average_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_SC_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_Hall_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_J1_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_J2_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_T10_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_T15_20_cell = cell(1, numel(plateaus_first_indices));
        plateau_average_T31_cell = cell(1, numel(plateaus_first_indices));
        
        plateau_average = zeros(numel(plateau_average_cell), 1);
        plateau_SC_average = zeros(numel(plateau_average_cell), 1);
        plateau_Hall_average = zeros(numel(plateau_average_cell), 1);
        plateau_J1_average = zeros(numel(plateau_average_cell), 1);
        plateau_J2_average = zeros(numel(plateau_average_cell), 1);
        plateau_T10_average = zeros(numel(plateau_average_cell), 1);
        plateau_T15_20_average = zeros(numel(plateau_average_cell), 1);
        plateau_T31_average = zeros(numel(plateau_average_cell), 1);
        
        SC_mV_on_plateaus = zeros(numel(plateau_average_cell), 1);
        Hall_on_plateaus = zeros(numel(plateau_average_cell), 1);
        J1_on_plateaus = zeros(numel(plateau_average_cell), 1);
        J2_on_plateaus = zeros(numel(plateau_average_cell), 1);
        T10_on_plateaus = zeros(numel(plateau_average_cell), 1);
        T15_20_on_plateaus = zeros(numel(plateau_average_cell), 1);
        T31_on_plateaus = zeros(numel(plateau_average_cell), 1);
        
        errors_SC = zeros(numel(plateau_average_cell), 1);
        errors_Hall = zeros(numel(plateau_average_cell), 1);
        errors_J1 = zeros(numel(plateau_average_cell), 1);
        errors_J2 = zeros(numel(plateau_average_cell), 1);
        errors_T10 = zeros(numel(plateau_average_cell), 1);
        errors_T15_20 = zeros(numel(plateau_average_cell), 1);
        errors_T31 = zeros(numel(plateau_average_cell), 1);
        
        plateau_middle = zeros(numel(plateau_average_cell), 1);
        indices_plateau_middle = zeros(numel(plateau_average_cell), 1);
        
        % Ciclo per estrarre i dati di ciascun plateau
        for i = 1:numel(plateaus_first_indices) - 1
        
            plateau_start(i) = plateaus_first_indices(i);
            plateau_end(i) = plateaus_first_indices(i + 1) -1;
            plateau_middle(i) = (plateaus_first_indices(i) + plateaus_first_indices(i + 1)) / 2;
        
            indices_plateau_start(i) = indices_nonrep_vector_filtered(plateau_start(i));
            indices_plateau_end(i) = indices_nonrep_vector_filtered(plateau_end(i));
            indices_plateau_middle(i) = round((indices_plateau_start(i)+indices_plateau_end(i)))/2;
        
            transient_start(i) = plateaus_first_indices(i + 1) - 1;
            transient_end(i) = plateaus_first_indices(i+1);
        
            indices_transient_start(i) = indices_nonrep_vector_filtered(transient_start(i));
            indices_transient_end(i) = indices_nonrep_vector_filtered(transient_end(i));
            
            plateau_start_isnan = any(isnan(plateau_start(i)));


            % Assegna i dati del plateau alla cella corrispondente e salva gli
            % indici dei plateau
            plateau_cell{i} = I_supply_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_SC_cell{i} = SC_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_Hall_cell{i} = Hall_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_J1_cell{i} = J1_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_J2_cell{i} = J2_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_T10_cell{i} = T10_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_T15_20_cell{i} = T15_20_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            plateau_T31_cell{i} = T31_mV_nonrep(indices_plateau_start(i):indices_plateau_end(i));
            indices_plateau_cell{i} = indices_nonrep_vector(indices_plateau_start(i):indices_plateau_end(i));

            % Assegna i dati del transitorio alla cella corrispondente e salva gli
            % indici dei plateau
            transient_cell{i} = I_supply_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_SC_cell{i} = SC_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_Hall_cell{i} = Hall_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_J1_cell{i} = J1_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_J2_cell{i} = J2_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T10_cell{i} = T10_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T15_20_cell{i} = T15_20_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T31_cell{i} = T31_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            indices_transient_cell{i} = indices_nonrep_vector(indices_transient_start(i):indices_transient_end(i));
            Time1_transient_cell{i} = Time_1_nonrep(indices_transient_start(i):indices_transient_end(i));
        
            % Calcola la media del plateau corrente e assegna alla cella delle
            % medie. calcola poi l'errore come standard deviation
            plateau_average_cell{i} = mean(plateau_cell{i});
            plateau_average_SC_cell{i} = mean(plateau_SC_cell{i});
            plateau_average_Hall_cell{i} = mean(plateau_Hall_cell{i});
            plateau_average_J1_cell{i} = mean(plateau_J1_cell{i});
            plateau_average_J2_cell{i} = mean(plateau_J2_cell{i});
            plateau_average_T10_cell{i} = mean(plateau_T10_cell{i});
            plateau_average_T15_20_cell{i} = mean(plateau_T15_20_cell{i});
            plateau_average_T31_cell{i} = mean(plateau_T31_cell{i});
        
            plateau_average(i) = [plateau_average_cell{i}];
            plateau_SC_average(i) = [plateau_average_SC_cell{i}];
            plateau_Hall_average(i) = [plateau_average_Hall_cell{i}];
            plateau_J1_average(i) = [plateau_average_J1_cell{i}];
            plateau_J2_average(i) = [plateau_average_J2_cell{i}];
            plateau_T10_average(i) = [plateau_average_T10_cell{i}];
            plateau_T15_20_average(i) = [ plateau_average_T15_20_cell{i}];
            plateau_T31_average(i) = [plateau_average_T31_cell{i}];
        
            errors_SC(i) = std( plateau_SC_cell{i});
            errors_Hall(i) = std(plateau_Hall_cell{i});
            errors_J1(i) = std(plateau_J1_cell{i});
            errors_J2(i) = std(plateau_J2_cell{i});
            errors_T10(i) = std(plateau_T10_cell{i});
            errors_T15_20(i) = std(plateau_T15_20_cell{i});
            errors_T31(i) = std(plateau_T31_cell{i});
        end


        %% clean transients
        % remove rising fraction of the transient
        for i = 1:numel(transient_cell)
            [max_value, max_index] = max(transient_SC_cell{i});
            indices_transient_start(i) = indices_transient_start(i) + (max_index-0);
        end 

        for i = 1:numel(transient_cell)
            Time1_transient_cell{i} = Time_1_nonrep(indices_transient_start(i):indices_transient_end(i));
            indices_transient_cell{i} = indices_nonrep_vector(indices_transient_start(i):indices_transient_end(i));
            transient_cell{i} = I_supply_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_SC_cell{i} = SC_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_Hall_cell{i} = Hall_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_J1_cell{i} = J1_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_J2_cell{i} = J2_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T10_cell{i} = T10_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T15_20_cell{i} = T15_20_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
            transient_T31_cell{i} = T31_mV_nonrep(indices_transient_start(i):indices_transient_end(i));
        end
        
        %remove overcurrent transient
        I_supply_Ic_position = find(I_supply_nonrep>50, 1);
        number_of_total_transients = numel(transient_cell);
        for i = 1:number_of_total_transients
            if indices_transient_start(i) > I_supply_Ic_position
                % Remove elements from the i-th position onwards
                transient_cell = transient_cell(1:i-1);
                indices_transient_cell = indices_transient_cell(1:i-1);
                transient_SC_cell = transient_SC_cell(1:i-1);
                transient_Hall_cell = transient_Hall_cell(1:i-1);
                transient_J1_cell = transient_J1_cell(1:i-1);
                transient_J2_cell = transient_J2_cell(1:i-1);
                transient_T10_cell = transient_T10_cell(1:i-1);
                transient_T15_20_cell = transient_T15_20_cell(1:i-1);
                transient_T31_cell = transient_T31_cell(1:i-1);
                Time1_transient_cell = Time1_transient_cell(1:i-1);
                % Break out of the loop since we're done scaling the cell array
                break;
            end
        end
        
        plateau_amount = numel(plateau_start);
        indices_plateau_vector = [];
        
        for i = 1:plateau_amount
            indices_plateau_vector = [indices_plateau_vector, indices_plateau_cell{i}];
        end
        
        %% Control plots
        if plot_check_bool == 1
            figure (10)
            hold on
            title('Plot the current plateaus and their averages')
            plot(I_supply_nonrep, '.')
            plot(indices_plateau_middle, plateau_average, 'rx',LineWidth=1)
            title('plateaus and their averages');
            xlabel('Time')
            ylabel('Ampère')
            legend('Supply current plateaus','Supply current plateaus average value')
            grid on
            hold off
            
            figure (11)
            hold on
            plot(T10_mV_nonrep, '.')
            title('check: T10 plateaus averages')
            plot(indices_plateau_middle, plateau_T10_average,'rx',LineWidth=1)
            xlabel('Time')
            ylabel('mV')
            legend('T10','T10 plateau average')
            hold off
            
            figure (12)
            hold on
            title('check: T15_20 plateaus averages')
            plot(T15_20_mV_nonrep, '.')
            plot(indices_plateau_middle, plateau_T15_20_average,'rx',LineWidth=1)
            xlabel('Time')
            ylabel('mV')
            legend('T15_20','T15_20 plateau average')
            hold off
            
            figure (13)
            hold on
            title('check: T31 plateaus averages')
            plot(T31_mV_nonrep, '.')
            plot(indices_plateau_middle, plateau_T31_average,'rx',LineWidth=1)
            xlabel('Time')
            ylabel('mV')
            legend('T15_20','T15_20 plateau average')
            hold off
            
            figure (14)
            hold on
            title('check: SC plateaus averages')
            plot(SC_mV_nonrep, '.')
            plot(indices_plateau_middle, plateau_SC_average,'rx',LineWidth=1)
            xlabel('Time')
            ylabel('mV')
            legend('SC','SC plateau average')
            hold off
            
            % plot I raw and each individual plateau. Check if plateau selection is
            % good or not
            figure (15)
            hold on
            title('Check plateaus considered')
            plot(I_supply_nonrep)
            for i = 1:numel(plateau_cell)
                plateau_indices = indices_plateau_start(i):indices_plateau_end(i);
                plateau_values = I_supply_nonrep(plateau_indices);
                plot(plateau_indices, plateau_values, '.');
            end
            xlabel('Time')
            ylabel('Ampère')
            
            %plot T10, T15 and T31 plateaus averages
            figure (16)
            hold on
            title('check: T10, T15 and T31  plateaus averages')
            plot(plateau_T10_average, '-g*', LineWidth=1)
            plot(plateau_T15_20_average,'-rx',LineWidth=1)
            plot(plateau_T31_average,'-bo',LineWidth=1)
            xlabel('Time')
            ylabel('mV')
            legend('T15_20','T31')
            hold off
        end

        % for i=1:numel(transient_cell)
        % figure(i)
        % % plot (transient_cell{i}, transient_SC_cell{i}, '.-')
        % plot (transient_SC_cell{i}, '.-')
        % end
        
        figure(123)
        hold on
        for i=1:numel(transient_cell)-1
        % plot (transient_cell{i}, transient_SC_cell{i}, '.-')
        plot (indices_transient_cell{i},transient_SC_cell{i}, '.-')
        end
        
        %% Remove unnecessary elements
        
        %remove errors last element
        errors_SC(length(errors_SC)) = [];
        errors_Hall(length(errors_Hall)) = [];
        errors_J1(length(errors_J1)) = [];
        errors_J2(length(errors_J2)) = [];
        errors_T10(length(errors_T10)) = [];
        errors_T15_20(length(errors_T15_20)) = [];
        errors_T31(length(errors_T31)) = [];
        
        %remove errors first element
        errors_SC(1) = [];
        errors_Hall(1) = [];
        errors_J1(1) = [];
        errors_J2(1) = [];
        errors_T10(1) = [];
        errors_T15_20(1) = [];
        errors_T31(1) = [];
        
        %remove errors last element again
        errors_SC(length(errors_SC)) = [];
        errors_Hall(length(errors_Hall)) = [];
        errors_J1(length(errors_J1)) = [];
        errors_J2(length(errors_J2)) = [];
        errors_T10(length(errors_T10)) = [];
        errors_T15_20(length(errors_T15_20)) = [];
        errors_T31(length(errors_T31)) = [];
        
        %remove plateau_average last element, first element, and last element again
        plateau_average(length(plateau_average)) = [];
        plateau_average(1) = [];
        plateau_average(length(plateau_average)) = [];
        
        %remove plateau_X_average last element
        plateau_SC_average(length(plateau_SC_average)) = [];
        plateau_Hall_average(length(plateau_Hall_average)) = [];
        plateau_J1_average(length(plateau_J1_average)) = [];
        plateau_J2_average(length(plateau_J2_average)) = [];
        plateau_T10_average(length(plateau_T10_average)) = [];
        plateau_T15_20_average(length(plateau_T15_20_average)) = [];
        plateau_T31_average(length(plateau_T31_average)) = [];
        
        %remove plateau_X_average first element
        plateau_SC_average(1) = [];
        plateau_Hall_average(1) = [];
        plateau_J1_average(1) = [];
        plateau_J2_average(1) = [];
        plateau_T10_average(1) = [];
        plateau_T15_20_average(1) = [];
        plateau_T31_average(1) = [];
        
        %remove plateau_X_average last element again
        plateau_SC_average(length(plateau_SC_average)) = [];
        plateau_Hall_average(length(plateau_Hall_average)) = [];
        plateau_J1_average(length(plateau_J1_average)) = [];
        plateau_J2_average(length(plateau_J2_average)) = [];
        plateau_T10_average(length(plateau_T10_average)) = [];
        plateau_T15_20_average(length(plateau_T15_20_average)) = [];
        plateau_T31_average(length(plateau_T31_average)) = [];
    end

    %% create a file.txt to store results
    meas_results_txt = createFile(folder_path, measurement_index);
    
    if ramp_bool == 0
        %% plot data without plateaus with a powerlaw fit, short sample model% Try fitting for T10 data
        try
            [fitresult_T10, gof_T10] = createFitT10(plateau_average, plateau_T10_average, errors_T10, I_supply, T10_mV, meas_results_txt, plot_bool, plots_folder_path);
        catch ME
            fprintf('Error in createFitT10: %s\n', ME.message);
        end
        
        % Try fitting for T15_20 data
        try
            [fitresult_T15_20, gof_T15_20] = createFitT15(plateau_average, plateau_T15_20_average, errors_T15_20, I_supply, T15_20_mV, meas_results_txt, plot_bool, plots_folder_path);
        catch ME
            fprintf('Error in createFitT15: %s\n', ME.message);
        end
        
        % Try fitting for T31 data
        try
            [fitresult_T31, gof_T31] = createFitT31(plateau_average, plateau_T31_average, errors_T31, I_supply, T31_mV, meas_results_txt, plot_bool, plots_folder_path);
        catch ME
            fprintf('Error in createFitT31: %s\n', ME.message);
        end
        
        % Try fitting for SC Modded Powerlaw data
        try
            [fitresult_mod, gof_mod] = PowerlawModFit(plateau_average, plateau_SC_average, errors_SC, I_supply, SC_mV, I_supply_nonrep, meas_results_txt, plot_bool, plots_folder_path);
        catch ME
            fprintf('Error in PowerlawModFit: %s\n', ME.message);
end
        %% transient fits
        tau_vector = zeros(1, numel(Time1_transient_cell));
        for i = 1:numel(Time1_transient_cell)
            try
            t = Time1_transient_cell{i};
            t = t(:);
            t1 = t(1);
            V = transient_SC_cell{i};
            V = V(:)./V(1);

            % Check if there are enough data points for fitting
            if numel(t) < 2 || numel(V) < 2
                disp('Insufficient data points for fitting.');
                continue; % Skip this iteration if there are not enough data points
            end

            exp_model = fittype(@(tau, t) exp((t1 - t) / tau), 'independent', 't', 'dependent', 'V');           
            % Fit the model to the data
            fitted_model = fit(t, V, exp_model);
            
            % Display the fitted model parameters
            disp('Fitted Parameters:');
            disp(fitted_model);
            
            %save tau
            tau_vector(i)=fitted_model.tau;
            % Plot the data and the fitted curve
            figure(i+500)
            plot(t, V, 'b.'); hold on;
            plot(fitted_model, 'r-');
            legend('Data', 'Fitted Curve');
            ylim([0 1]);
            xlabel('x');
            ylabel('y');
            title('Fit of Data to a Decreasing Exponential');
            catch ME
                fprintf('Error in transient fit: %s\n', ME.message);
            end
        end
    % make the tau average
    tau_average = mean(tau_vector);
    tau_error = std(tau_vector);
    Radial_R = inductance/tau_average;

    fprintf(meas_results_txt, 'tau average\t%f\n', tau_average);
    fprintf(meas_results_txt, 'tau error\t%f\n', tau_error);
    fprintf(meas_results_txt, 'radial R\t%f\n', Radial_R);
    end

if ramp_bool == 1
    % Attempt to fit T10 Ramp data
    try
        [fitresult_T10, gof_T10] = createFitT10Ramp(I_supply_nonrep, T10_mV_nonrep, meas_results_txt, plots_folder_path);
    catch ME
        fprintf('Error with T10 Ramp fit: %s\n', ME.message);
    end

    % Attempt to fit T15 Ramp data
    try
        [fitresult_T15_20, gof_T15] = createFitT15Ramp(I_supply_nonrep, T15_20_mV_nonrep, meas_results_txt, plots_folder_path);
    catch ME
        fprintf('Error with T15 Ramp fit: %s\n', ME.message);
    end

    % Attempt to fit T31 Ramp data
    try
        [fitresult_T31, gof_T31] = createFitT31Ramp(I_supply_nonrep, T31_mV_nonrep, meas_results_txt, plots_folder_path);
    catch ME
        fprintf('Error with T31 Ramp fit: %s\n', ME.message);
    end

    % Attempt to fit SC Ramp data
    try
        [fitresult_mod, gof_mod] = SC_fit_ramp_T31like(I_supply_nonrep, SC_mV_nonrep, meas_results_txt, plots_folder_path);
    catch ME
        fprintf('Error with SC Ramp fit: %s\n', ME.message);
    end
end


    %% Plot fits together
    if plot_bool == 1
        figure('Name', 'untitled fit 1');
        hold on
        % Generate x-values for plotting
        x_values = linspace(0, 85, 100);  % Adjust the range and number of points as needed
        % Plot fitted curves
        h_T10 = plot(x_values, feval(fitresult_T10, x_values), 'color', 'red');
        h_T15_20 = plot(x_values, feval(fitresult_T15_20, x_values), 'color', 'blue');
        h_T31 = plot(x_values, feval(fitresult_T31, x_values), 'color', 'green');
        h_SC = plot(x_values, feval(fitresult_mod, x_values), 'color', 'black');
        % Add legend
        legend('T10', 'T15,20', 'T31', 'SC')
        % Label axes
        xlabel('abs_plateau_average', 'Interpreter', 'none');
        ylabel('abs_plateaus_SC_average', 'Interpreter', 'none');
        % Set axes limits
        ylim([-6, 25]);
        xlim([0, 85]);
        grid on
    end

    %% close the file
    fclose(meas_results_txt);

    % if ramp_bool~=0
end
toc
