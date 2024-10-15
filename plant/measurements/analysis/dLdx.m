clc
clear variables
close all

%% Get number of files to be loaded

files_data = struct( ...
    'path', 'realtime\measurements\data\Induttanza', ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\*.mat']);
files_data.N_files = length(files_data.dir_content);


%% Load data

data = repmat( ...
        struct( ...
            'time', [], ...
            'position', [], ...
            'velocity', [], ...
            'current', [], ...
            'voltage', []), ...
        1, ...
        files_data.N_files);

for file_idx = 1:files_data.N_files
    data(file_idx) = load_data([files_data.path '\' files_data.dir_content(file_idx).name]);
end

clear file_idx


%% Compute dL(x)/dx/dx @ Fem == Fg
% Basically, when the ball starts moving, that our point of interest.
% Knowing the initial position, and computing the current when the ball
% starts moving, we automatically get dL(x)/dx

g = 9.81; %[m/s^2]
m = 61.57e-3; %[Kg]
sensitivity_equation = @(current) -g * 2*m / current^2;

position = zeros(files_data.N_files, 1);
current = zeros(files_data.N_files, 1);
sensitivity = zeros(files_data.N_files, 1);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    position_jump_idx = find(diff(measurements.position) < -1.0e-3, 1, 'first');

    position(file_idx) = mean(measurements.position(1:floor(0.9 * position_jump_idx)));
    current(file_idx) = measurements.current(position_jump_idx);
    sensitivity(file_idx) = sensitivity_equation(current(file_idx));

end

% Model fitting

L1_guess = 0.017521; %[H]
a_guess = 1 / 0.0058231; %[1/m]
coefficients_guess = [L1_guess a_guess];

fitted_model = fitnlm( ...
    [position], sensitivity, ...
    @sensitivity_inductance_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

L1 = fitted_model.Coefficients.Estimate(1);
a = fitted_model.Coefficients.Estimate(2);


%% Dependence of the current over the voltage input

p = zeros(2, files_data.N_files);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);
    p(:, file_idx) = polyfit(measurements.voltage, measurements.current, 1);

end

p = mean(p);


%% Plots
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');

nexttile
hold on
grid on

plot(position, sensitivity, 'ko');
plot(position, sensitivity_inductance_model(position, [L1 a]), 'r');

title('Inductance sensitivity to object distance \frac{dL}{dx}')
xlabel('Distance [m]')
ylabel('dL/dx [H/m]')
legend('Measured', 'Fitted model')



%% Functions

function sensitivity = sensitivity_inductance_model(b, x)

position = x(:, 1);
L1 = b(1);
a = b(2);

sensitivity = -a*L1 * exp(-a*position);

% Sanity checks for fitnlm stability
sensitivity(isinf(sensitivity)) = sign(x(isinf(sensitivity))) .* 1e100;
sensitivity(isnan(sensitivity)) = 1e100;

end