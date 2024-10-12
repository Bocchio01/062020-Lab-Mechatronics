clc
clear variables
close all

%% MagLev parameters

R = 150; %[ohm]


%% PICO connection


%% MagLev connection and parameter estimation

V_initial = 0;
V_final = 2;

sim("realtime\characterization\input_linear");


I_max = V_final / R;
current_model = @(coefficients, time) I_max * (1 - exp(- time(:, 1) ./ (coefficients(1)/R)));
coefficients_guess = [1.7 * 1e-3]; %[H]

fitted_model = fitnlm(table(out.time, PICO.current), current_model, coefficients_guess);
coefficients = fitted_model.Coefficients{:, 'Estimate'};
L0(sim_idx) = coefficients(1);


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');

figure('Name', 'Dynamic of the current');

nexttile
hold on
grid on
colororder({'k','r'})

yyaxis right
plot( ...
    [0 t_start t_start max(sim.tout)], ...
    [V_initial V_initial V_final V_final], ...
    'LineWidth', 1);

yyaxis left
plot(PICO.time, PICO.current, 'r', 'LineWidth', 2);
plot(PICO.time, current_model(coefficients, PICO.time), 'r', 'LineWidth', 2);

title('Current in the coil')
xlabel('Time [s]')

yyaxis right
ylabel('Voltage [V]')

yyaxis left
ylabel('Current [A]')

legend('Step input', 'Measured current', 'Fitted current')