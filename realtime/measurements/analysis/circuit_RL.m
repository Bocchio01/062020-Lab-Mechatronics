clc
clear variables
close all

%% Loading measurement data

data = load('realtime\measurements\data\_last.mat').measurements;
time = data(1, :);
current = data(4, :);
voltage = data(6, :);

% Initialize parameters (guess for L)
R_guess = 10;  % [ohm]
L_guess = 0.1; % [H]


%% Defining current model
% Find the total duration and sample rate
total_time = max(time);
dt = time(2) - time(1); % Assuming time is uniformly spaced
samples_per_second = 1 / dt;
num_subrecords = floor(total_time);  % Number of 1-second intervals

% Define the model for the current in the RL circuit
current_model = @(coefficients, t) coefficients(2) * (1 - exp(-t * coefficients(1) / R_guess));
%%
% 

% Loop through each 1-second subrecord
for i = 1:num_subrecords
    % Extract the data for the current subrecord (1-second interval)
    idx_start = (i-1) * samples_per_second + 1;
    idx_end = i * samples_per_second;
    
    t_sub = time(idx_start:idx_end);
    current_sub = current(idx_start:idx_end);
    voltage_sub = voltage(idx_start:idx_end);
    
    % Estimate I_max from the square wave peak (assuming it's a step response)
    I_max = max(current_sub);
    
    % Fit the model to the data using nonlinear regression
    coefficients_guess = [L_guess, I_max];  % Initial guess for [L, I_max]
    fitted_model = fitnlm(t_sub, current_sub, current_model, coefficients_guess);
    
    % Extract the estimated parameters
    L_estimated = fitted_model.Coefficients.Estimate(1);  % Estimated inductance
    I_max_estimated = fitted_model.Coefficients.Estimate(2);  % Estimated max current
    
    % Compute the fitted current based on the estimated parameters
    fitted_current = current_model([L_estimated, I_max_estimated], t_sub);
    
    % Plot the actual and fitted current
    figure;
    plot(t_sub, current_sub, 'b', 'LineWidth', 1.5); % Original current
    hold on;
    plot(t_sub, fitted_current, 'r--', 'LineWidth', 1.5); % Fitted current
    xlabel('Time [s]');
    ylabel('Current [A]');
    title(['Subrecord ' num2str(i) ': Fitted RL Circuit']);
    legend('Actual current', 'Fitted current');
    hold off;
    
    % Display the estimated parameters for this subrecord
    disp(['Subrecord ' num2str(i) ':']);
    disp(['Estimated L: ' num2str(L_estimated) ' H']);
    disp(['Estimated I_max: ' num2str(I_max_estimated) ' A']);
    disp('-----------------------------');
end
