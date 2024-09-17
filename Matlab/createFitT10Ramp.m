function [fitresult, gof] = createFitT10Ramp(I_supply_nonrep, T10_mV_nonrep, meas_results_txt, plots_folder_path)
%CREATEFIT(I_SUPPLY_NONREP_FILTERED,T10_MV_NONREP_FILTERED)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input: I_supply_nonrep_filtered
%      Y Output: T10_mV_nonrep_filtered
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 18-Mar-2024 14:53:10


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( I_supply_nonrep, T10_mV_nonrep);

% Set up fittype and options.
ft = fittype( '(100*10^-3)*1.92*(abs(I/I_c))^(n)', 'independent', 'I', 'dependent', 'V' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -Inf];
opts.StartPoint = [0.317099480060861 0.0344460805029088];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%% Store the coefficient values in a proper variable
coeff_values = coeffvalues(fitresult);
I_c_value = coeff_values(1); % I_c is the first coefficient
n_value = coeff_values(2); % n is the second coefficient
%% save results into a txt
fprintf(meas_results_txt, 'T10\t%f\t%f\t%f\n', I_c_value, n_value, gof.rsquare);

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'T10_mV_nonrep vs. I_supply_nonrep', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'I_supply_nonrep_filtered', 'Interpreter', 'none' );
ylabel( 'T10_mV_nonrep_filtered', 'Interpreter', 'none' );
grid on
    % Specify a custom filename
    file_name = 'T10_ramp_fit.fig';
    
    % Full file path (combine folder and filename)
    full_path = fullfile(plots_folder_path, file_name);
    
    % Save the plot in .fig format
    savefig(full_path);

