clc
% clear variables
close all

%% MagLev parameters

R = 4.5; %[ohm]
% R = 4.4; %[ohm]


%% MagLev connection and parameter estimation

t_start = 1;
V_initial = 0;
V_final = 5;

% sim("realtime\characterization\input_step");

%%

I_max = 2.55;
current_model = @(coefficients, time) I_max * (1 - exp(- time(:, 1) ./ (coefficients(1)/R)));
coefficients_guess = 0.125; %[H]

fitted_model = fitnlm(table([0:200]'/200, simout), current_model, coefficients_guess);
coefficients = fitted_model.Coefficients{:, 'Estimate'};
L0 = coefficients(1);


%% Plots

reset(0)
% set(0, 'DefaultFigureNumberTitle', 'off');
% set(0, 'DefaultFigureWindowStyle', 'docked');

figure('Name', 'Dynamic of the current');

nexttile
hold on
grid on
% colororder({'k','r'})

% yyaxis right
% plot( ...
%     [0 t_start t_start max(sim.tout)], ...
%     [V_initial V_initial V_final V_final], ...
%     'LineWidth', 1);

% yyaxis left
plot([0:200]/200, simout, 'r', 'LineWidth', 1);
plot([0:200]/200, current_model(coefficients, [0:200]'/200), 'b', 'LineWidth', 2);

title('Current in the coil')
xlabel('Time [s]')

% yyaxis right
ylabel('Voltage [V]')

% yyaxis left
ylabel('Current [A]')

legend('Measured current', 'Fitted current')