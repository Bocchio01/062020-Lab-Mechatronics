% clc
% clear variables
% close all

%% Experimental data from manual sampling of:
% 'PID_gain_scheduling - KF'
% 'LQR_tracking - low_pass'

position = [
    9 8 9 10 10.98 12 ...
    9.8 8.97 9.77 10.61 11.46 12.34
    ]' * 1e-3;

I_op = [
    0.88 0.805 0.88 0.96 1.039 1.12 ...
    0.94 0.87 0.93 0.998 1.06 1.135
    ]';

[position, sorting_order] = sort(position);
I_op = I_op(sorting_order);


%% Optimization of [Lz, az]

% Model fitting
Lz_guess = 0.0334; %[H]
az_guess = 183.3; %[1/m]
coefficients_guess = [Lz_guess az_guess];

fitted_model = fitnlm( ...
    position, I_op, ...
    @I_op_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

Lz = fitted_model.Coefficients.Estimate(1);
az = fitted_model.Coefficients.Estimate(2);


%% Results

fprintf([ ...
    'F(z, I) characterization (EM1):\n' ...
    '\taz:\t%d\n' ...
    '\tLz:\t%d\n' ...
    ], az, Lz);


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultLineLineWidth', 1);
set(0, 'defaultaxesfontsize', 12);

figure_results = figure('Name', 'Results analysis');
tiles = tiledlayout(2, 2);


PID_simout = load('results\multisteps_stairs\PID_gain_scheduling - KF.mat').logouts;
LQR_simout = load('results\multisteps_stairs\LQR_tracking - low_pass.mat').logouts;
time = PID_simout(1, :)';
ref = PID_simout(2, :)';
PID_simout = filter((1/500) * ones(1, 500), 1, PID_simout, [], 2);
LQR_simout = filter((1/500) * ones(1, 500), 1, LQR_simout, [], 2);
PID_z = PID_simout(3, :)';
PID_I1 = PID_simout(5, :)';
LQR_z = LQR_simout(3, :)';
LQR_I1 = LQR_simout(5, :)';

% Position data
position_tile = nexttile(tiles, 1);
hold on
grid on

plot(time, PID_z * 1000, 'DisplayName', 'PID gain-scheduling (filtered)')
plot(time, LQR_z * 1000, 'DisplayName', 'LQR tracking (filtered)')

ylim([0.9*min(ref) 1.1*max(ref)]*1000)
set(gca, 'YDir', 'reverse')

ylim([7.5 13])

title('Position data')
xlabel('Time [s]')
ylabel('Position [mm]')
legend()


% Coils data
coils_tile = nexttile(tiles, 3);
hold on
grid on

plot(time, PID_I1, 'DisplayName', 'PID gain-scheduling (filtered)')
plot(time, LQR_I1, 'DisplayName', 'LQR tracking (filtered)')

ylim([0.75 1.25])

title('Coils data')
xlabel('Time [s]')
ylabel('Current [A]')
legend()

linkaxes([position_tile coils_tile], 'x')
xlim([2.5 15])


nexttile(tiles, 2, [2, 1])
hold on
grid on

load("parameters_lagrangian.mat", "L1z", "a1z");
plot(position * 1000, I_op, 'ok', 'DisplayName', 'Experimental')
plot(position * 1000, I_op_model([Lz az], position), 'LineWidth', 1.5, 'DisplayName', 'Interpolated');
plot(position * 1000, I_op_model([3.438228e-02 1.837302e+02], position), 'LineWidth', 1.5, 'DisplayName', 'Identified');

axis padded
title('Operating point analysis')
xlabel('z_{op} [mm]')
ylabel('I1_{op} [A]')
legend()

try %#ok<TRYNC>
    % export_pdf_graphic(gcf, '/identification/operating_point_analysis');
end


%% Functions

function I_op = I_op_model(b, x)

z = x(:, 1);
Lz = b(1);
az = b(2);

load("parameters_lagrangian.mat", "m", "g");

dL1dx = @(x) -az*Lz .* exp(-az*x);
I_op = sqrt( -2*m*g ./ dL1dx(z) );

% Sanity checks for fitnlm stability
I_op(isinf(I_op)) = sign(x(isinf(I_op))) .* 1e100;
I_op(isnan(I_op)) = 1e100;

end