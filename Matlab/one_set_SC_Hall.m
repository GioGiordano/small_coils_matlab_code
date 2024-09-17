function one_set_SC_Hall(i, Time_1, Time_2, Hall_mV, SC_mV, J1_mV, J2_mV, T10_mV, T15_20_mV, T31_mV)
    i=i;
    
    %creazione di un filtro passabasso
    d1 = designfilt("lowpassiir",FilterOrder=1, ...
    HalfPowerFrequency=0.5,DesignMethod="butter");
    %applicazione del filtro passabasso
    Hall_mV_filt = filtfilt(d1, Hall_mV);
    
    % Hall in kGauss and Tesla
    Hall_kGauss_filt = Hall_mV_filt/1.022;
    Hall_Tesla_filt = Hall_kGauss_filt*(10^(-1));

    %figure
    %plot(Time_1, Hall_mV,Time_1, Hall_mV_filt); hold on
    figure ('Name',sprintf('Field and SC, Measurement %i',i))
    title  (sprintf('Field and SC, Measurement %i',i))
    hold on
    xlabel ('Time [s]')
    yyaxis left
    ylabel ('Field [T]')
    plot(Time_1,Hall_Tesla_filt,'.'); 
    yyaxis right
    ylabel ('SC [mV]')
    plot(Time_1,SC_mV);
