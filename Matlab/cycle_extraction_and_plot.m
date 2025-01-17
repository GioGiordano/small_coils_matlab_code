function cycle_extraction_and_plot();

measurement_index = ["01"; "02";"03";"04";"05";"06";"07";"08";"09";"10"];
i=1
directory = '20240115_hall_test';

for i=1:10
        % extract data and fix measurement units
        % i = measurement_index;
        % Costruisce il nome del file TDMS utilizzando la funzione sprintf, dove %i è sostituito con il valore corrente di i
        dataname = fullfile('..',directory,'RawData',sprintf('Test%s.tdms', measurement_index(i)));
        % Legge i dati dal file TDMS utilizzando la funzione tdmsread e li memorizza nell'elemento i di una cella denominata Data
        Data{i} = tdmsread(dataname);
        % Prima colonna dei dati
        Time_1 = table2array(Data{i} {1,1}(:,1));
        % Differenza tra la seconda colonna dei dati e il primo elemento della seconda colonna.
        Time_2 = table2array(Data{i} {1,1}(:,2)) - table2array(Data{i} {1,1}(1,2));
        % estrazione dei dati
        Hall_mV = 1e3*table2array(Data{i} {1,1}(:,3));
        SC_mV = 1e3*table2array(Data{i} {1,1}(:,5));
        I_supply = 1e3*table2array(Data{i} {1,1}(:,4));
        J1_mV = 1e3*table2array(Data{i} {1,1}(:,6));
        J2_mV = 1e3*table2array(Data{i} {1,1}(:,10)); 
        T10_mV = 1e3*table2array(Data{i} {1,1}(:,7));
        T15_20_mV = 1e3*table2array(Data{i} {1,1}(:,8));
        T31_mV = 1e3*table2array(Data{i} {1,1}(:,9));
    
    %creazione di un filtro passabasso
    d1 = designfilt("lowpassiir",FilterOrder=1, ...
    HalfPowerFrequency=0.5,DesignMethod="butter");
    %applicazione del filtro passabasso
    Hall_mV_filt = filtfilt(d1,Hall_mV);

    % Assuming I_supply is your data that you want to filter
    % You can adjust the window size based on your needs
    windowSize = 100;
    
    % Apply a moving average filter
    filtered_I_supply = smoothdata(I_supply, 'movmean', windowSize);

    %figure
    %plot(Time_1, Hall_mV,Time_1, Hall_mV_filt); hold on
    figure
    yyaxis left
    plot(Time_1,Hall_mV); hold on

    yyaxis right
    plot(Time_1,SC_mV);

    i=i+1
end