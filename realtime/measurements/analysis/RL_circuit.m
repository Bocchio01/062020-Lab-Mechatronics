clc
clear variables
close all

%% Load measurements of RL current dynamic

% file_path = 'realtime\measurements\data\RL_circuit\*.mat';
file_path = 'realtime\measurements\data\Induttanza\Induttanza2.mat';
electromagnet_idx = 1;
data = load_data(file_path, electromagnet_idx);


%% Transients search

transient_idxs = find(abs(diff(data.voltage)) > 0.1);
N_subrecords = length(transient_idxs);

assert(N_subrecords ~= 0, 'No transients found in the current measurement data')


%% Fitting the dynamics of the RL circuit

R_guess = 0.450; %[ohm]
L_guess = 0.125; %[H]

coefficients_guess = [R_guess L_guess];

R_estimations = zeros(N_subrecords, 1);
L_estimations = zeros(N_subrecords, 1);

for record_idx = 1:2:N_subrecords-1

    start_idx = transient_idxs(record_idx);
    final_idx = transient_idxs(record_idx + 1) - 1;

    current = data.current(start_idx+1 : final_idx+1);
    voltage = data.voltage(start_idx+0 : final_idx+0);
    time = 0.005 * (0:length(voltage)-1)';

    fitted_model = fitnlm( ...
        [time voltage], current, ...
        @current_model, coefficients_guess, ...
        'Options', statset('TolFun', 1e-10));

    R_estimations(record_idx) = fitted_model.Coefficients.Estimate(1);
    L_estimations(record_idx) = fitted_model.Coefficients.Estimate(2);

end

R = mean(R_estimations(1:2:N_subrecords-1));
L = mean(L_estimations(1:2:N_subrecords-1));

fprintf([ ...
    'Electromagnet EM%d:\n' ...
    '\tInductance L:\t%d\n' ...
    '\tResistance R:\t%d\n' ...
    ], electromagnet_idx, R, L);

clear R_guess L_guess coefficients_guess record_idx start_idx final_idx current voltage time fitted_model



%% Plots

reset(0);
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');

nexttile
hold on
grid on

for record_idx = 1:2:N_subrecords-1

    start_idx = transient_idxs(record_idx);
    final_idx = transient_idxs(record_idx + 1) - 1;

    current = data.current(start_idx+1 : final_idx+1);
    voltage = data.voltage(start_idx+0 : final_idx+0);
    time = 0.005 * (0:length(voltage)-1)';

    plot(time, current, '--k');
    plot(time, current_model([R, L], [time voltage]), 'r')

end

title('RL circuit model fitting')
xlabel('Time [s]')
ylabel('Current [A]')
legend('Measured', 'Fitted')


clear transient_idxs record_idx start_idx final_idx current voltage time 


%% Functions

function I = current_model(b, x)

t = x(:, 1);
V = x(:, 2);
R = b(1);
L = b(2);

I = V(end) / R - (V(end) - V(1)) / R * exp(-1 * R / L * t);

% Sanity checks for fitnlm stability
I(isinf(I)) = sign(x(isinf(I))) .* 1e100;
I(isnan(I)) = 1e100;

end