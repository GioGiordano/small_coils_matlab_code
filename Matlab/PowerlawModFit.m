function [fitresult_mod, gof_mod] = PowerlawModFit(plateau_average, plateau_SC_average, errors, I_supply, SC_mV, I_supply_nonrep, meas_results_txt, plot_bool,plots_folder_path)
%CREATEFIT(ABS_PLATEAU_AVERAGE,ABS_PLATEAUS_SC_AVERAGE,WEIGHT)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input: abs_plateau_average
%      Y Output: abs_plateaus_SC_average
%      Weights: weight
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 16-Feb-2024 16:59:27

% %% error definition
% abs_plateau_average = abs(plateau_average);
% abs_plateau_SC_average = abs(plateau_SC_average);
% weight = 1./errors.^2;

%% error definition
abs_plateau_average = abs(plateau_average);
abs_plateau_SC_average = abs(plateau_SC_average);
weight = errors.^-2;
for i = 1:length(weight)
    if weight(i) == inf
        vector_correction = [0.001,  0.002];
        weight(i) = std(vector_correction);
    end
end

%% define constants
V_th = (100*10^-3)*6;
n_0 = 29.34;
I_0 = 98.76;


%% Fit: 'untitled fit 1'.
[xData, yData, weights] = prepareCurveData( abs_plateau_average, abs_plateau_SC_average, weight);

% Set up fittype and options.
ft = fittype( '(100*10^-3)*6*(abs(I/(98.76+m_I*I)))^(29.34+m_n*I)', 'independent', 'I', 'dependent', 'V' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.830828627896291 0.473288848902729];
opts.Upper = [1e-10 Inf];
opts.Weights = weights;

% Fit model to data.
[fitresult_mod, gof_mod] = fit( xData, yData, ft, opts );

%% Store the coefficient values in a proper variable
coeff_values = coeffvalues(fitresult_mod);
m_I_value = coeff_values(1); % I_c is the first coefficient
m_n_value = coeff_values(2); % n is the second coefficient

%% compute I_c and n
V = (V_th.*(I_supply_nonrep./(I_0+m_I_value.*I_supply_nonrep)).^(n_0+m_n_value.*I_supply_nonrep));
V_diff = abs(V - V_th);
[V_diff_min, V_diff_min_index] = min(V_diff);
I_c = I_0+m_I_value*I_supply_nonrep(V_diff_min_index);
n = n_0+m_n_value*I_supply_nonrep(V_diff_min_index);

%% Create the Title
title_str = sprintf('Rsquare = %f, m_I = %f [A], m_n = %f I_c = %.2f, n = %.2f', gof_mod.rsquare, m_I_value, m_n_value, I_c, n);

%% save results into a txt
fprintf(meas_results_txt, 'SC\t%f\t%f\t%f\n', I_c, n, gof_mod.rsquare);

%% Plot fit with data.
if plot_bool == 1
    figure( 'Name', 'untitled fit 1' );
    hold on
    title(title_str);
    plot(I_supply, SC_mV,'o', 'MarkerEdgeColor', [0.8 0.8 0.8])
    errorbar(plateau_average, plateau_SC_average, errors, '.')
    h = plot( fitresult_mod, xData, yData );
    legend( h, 'abs_plateaus_SC_average vs. abs_plateau_average with weight', 'untitled fit 1', 'Location', 'best', 'Interpreter', 'none' );
    % Label axes
    xlabel( 'abs_plateau_average', 'Interpreter', 'none' );
    ylabel( 'abs_plateaus_SC_average', 'Interpreter', 'none' );
    % axes limiter
    ylim([-6,25]);
    xlim([0, 85]);
    grid on
    % Specify a custom filename
    file_name = 'SC_fit.fig';
    
    % Full file path (combine folder and filename)
    full_path = fullfile(plots_folder_path, file_name);
    
    % Save the plot in .fig format
    savefig(full_path);
end 

