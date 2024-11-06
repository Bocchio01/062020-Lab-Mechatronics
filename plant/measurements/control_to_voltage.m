clc
clear variables
close all

%% Data

measurements.pwm = 0:0.1:1;
measurements.voltage = [0.043 0.613 1.768 2.93 4.10 5.26 6.43 7.59 8.80 9.96 11.06];

p = polyfit(measurements.pwm(2:end), measurements.voltage(2:end), 1);

voltage_min = min(measurements.voltage);
PWM_min = (voltage_min - p(2)) / p(1);

voltage = @(PWM) ...
    (PWM < PWM_min) .* (voltage_min) + ...
    (PWM >= PWM_min) .* (p(1) * PWM + p(2));


%% Parameters

fprintf([ ...
    'Control to Voltage:\n' ...
    '\tMinimum voltage V_min:\t%d\n' ...
    '\tMinimum control U_min:\t%d\n' ...
    '\tLinear model slope k_i:\t%d\n' ...
    '\tLinear model intercept c_i:\t%d\n'
    ], voltage_min, PWM_min, p(1), p(2));


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure('Name', 'Control to voltage analysis')

nexttile
hold on
grid on

plot(measurements.pwm, measurements.voltage, 'ok');
fplot(@(PWM) U_to_V(PWM), [0 1], 'r', 'LineWidth', 2);
fplot(@(PWM) p(1) * PWM + p(2), [0 1], 'k--');

a = [cellstr(num2str(get(gca,'xtick')' * 100))]; 
pct = char(ones(size(a, 1), 1) * '%'); 
set(gca, 'xticklabel', [char(a), pct])

title('Dependence of coil voltage to control output')

xlabel('PWM Control [%]')
ylabel('Upper coil voltage [V]')
legend('Measured data', 'Fitting')

export_pdf_graphic(gcf, '/measurements/control_to_voltage');