clc
clear variables
% close all

%% Get number of files to be loaded

electromagnet_idx = 1;
file_path = 'identification\data\inductance\';

files_data = struct( ...
    'path', file_path, ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\' num2str(electromagnet_idx) '*.mat']);
files_data.N_files = length(files_data.dir_content);


%% Load data

data = repmat( ...
    struct( ...
    'time', [], ...
    'position', [], ...
    'velocity', [], ...
    'current', [], ...
    'control', [], ...
    'voltage', []), ...
    1, ...
    files_data.N_files);

for file_idx = 1:files_data.N_files
    data(file_idx) = load_data([files_data.path '\' files_data.dir_content(file_idx).name], electromagnet_idx);
end

clear file_idx


%% Fitting current transient to compute L and annotate z, I

N_transients_max = 10;

current = cell(files_data.N_files, N_transients_max);
voltage = cell(files_data.N_files, N_transients_max);
time = cell(files_data.N_files, N_transients_max);

z = zeros(files_data.N_files, N_transients_max);
I = zeros(files_data.N_files, N_transients_max);
L = zeros(files_data.N_files, N_transients_max);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);
    transient_idxs = find(abs(diff(measurements.voltage)) > 0.1);

    % Fitting current dynamics to compute L
    L_guess = 0.125; %[H]

    coefficients_guess = L_guess;

    for transient_idx = 1:length(transient_idxs)/2

        start_idx = transient_idxs(2*transient_idx - 1);
        % final_idx = transient_idxs(2*transient_idx + 0) - 1;
        final_idx = start_idx + 60;

        current{file_idx, transient_idx} = measurements.current(start_idx+1 : final_idx+1);
        voltage{file_idx, transient_idx} = measurements.voltage(start_idx+0 : final_idx+0);
        time{file_idx, transient_idx} = measurements.time(start_idx : final_idx) - measurements.time(start_idx);

        fitted_model = fitnlm( ...
            [time{file_idx, transient_idx} voltage{file_idx, transient_idx}], current{file_idx, transient_idx}, ...
            @current_model, coefficients_guess, ...
            'Options', statset('TolFun', 1e-10));

        z(file_idx, transient_idx) = mean(measurements.position);
        I(file_idx, transient_idx) = mean(current{file_idx, transient_idx}(floor(1/2 * length(current)):end));
        L(file_idx, transient_idx) = fitted_model.Coefficients.Estimate(1);

    end

end

z = z(z~=0);
I = I(I~=0);
L = L(L~=0);


%% Fitting our experimental model over the previously computed L(z, I)

L0_guess = 5e-2; %[H]
az_guess = 2e+3; %[1/m]
Lz_guess = 3e-3; %[H]
aI_guess = 5e+0; %[m/A]
bI_guess = 1e-0; %[m]
LI_guess = 4e-3; %[H]

coefficients_guess = [L0_guess az_guess Lz_guess aI_guess bI_guess LI_guess];

fitted_model = fitnlm( ...
    [z I], L, ...
    @inductance_model, coefficients_guess, ...
    'Options', statset('TolFun', 1e-10));

L0 = fitted_model.Coefficients.Estimate(1);
az = fitted_model.Coefficients.Estimate(2);
Lz = fitted_model.Coefficients.Estimate(3);
aI = fitted_model.Coefficients.Estimate(4);
bI = fitted_model.Coefficients.Estimate(5);
LI = fitted_model.Coefficients.Estimate(6);


%% Results

fprintf([ ...
    'L(z, I) characterization (EM%d):\n' ...
    '\tL0:\t%d\n' ...
    '\taz:\t%d\n' ...
    '\tLz:\t%d\n' ...
    '\taI:\t%d\n' ...
    '\tbI:\t%d\n' ...
    '\tLI:\t%d\n' ...
    ], electromagnet_idx, L0, az, Lz, aI, bI, LI);



%% Plots

reset(0);
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

% Current dynamics fitting
figure_I = figure('Name', 'Inductance analysis');
nexttile

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);

    for transient_idx = 1:length(find(diff(measurements.voltage) > 0.1))

        plot3( ...
            time{file_idx, transient_idx}, ...
            z(file_idx + transient_idx - 1) * ones(length(time{file_idx, transient_idx}), 1) * 1000, ...
            current{file_idx, transient_idx}, ...
            'k');

        hold on
        grid on

        % plot3( ...
        %     time{file_idx, transient_idx}, ...
        %     z(file_idx + transient_idx - 1) * ones(200, 1) * 1000, ...
        %     current_model(L(file_idx, transient_idx), [time{file_idx, transient_idx} voltage{file_idx, transient_idx}]), ...
        %     'r')

    end

end

view([30 7])

title('Current dynamics experimental data')
xlabel('Time [s]')
ylabel('Position [mm]')
zlabel('Current [A]')
legend('Measured')


% % Current dynamics fitting (visualization of a single distance test)
% nexttile
% hold on
% grid on
% 
% for file_idx = 10
% 
%     measurements = data(file_idx);
% 
%     for transient_idx = 1:length(find(diff(measurements.voltage) > 0.1))
% 
%         plot( ...
%             time{file_idx, transient_idx}, ...
%             current{file_idx, transient_idx}, ...
%             'k');
% 
%         plot( ...
%             time{file_idx, transient_idx}, ...
%             current_model(L(file_idx + transient_idx - 1), [time{file_idx, transient_idx} voltage{file_idx, transient_idx}]), ...
%             'r', ...
%             'LineWidth', 2)
% 
%     end
% 
% end
% 
% 
% title(['Current dynamics fitting @z=' num2str(z(file_idx, 1) * 1000) 'mm'])
% xlabel('Time [s]')
% ylabel('Current [A]')
% legend('Measured', 'Fitted')
% 
% 
% % Inductance modelling and fitting
% figure_L = figure('Name', 'Inductance modelling and fitting');
% tiledlayout(1, 2)
nexttile

plot3(z * 1000, I, L, 'k*', 'LineWidth', 3)
hold on
grid on

[Z_grid, I_grid] = meshgrid(linspace(0, max(z), 30), linspace(0, max(I), 30));
surf(Z_grid * 1000, I_grid, reshape(inductance_model([L0, az, Lz, aI, bI, LI], [Z_grid(:), I_grid(:)]), size(Z_grid)), 'EdgeColor', 'k', 'FaceAlpha', 0.8);

axis padded
view([65 35])
colormap(jet(64));
colorbar

title('Inductance modelling L(z, I)');
xlabel('z [mm]');
ylabel('I [A]');
zlabel('L [H]');
legend('Experimental data', 'Fitted inductance model', 'Location', 'best')

try %#ok<TRYNC>
    export_pdf_graphic(figure_I, '/measurements/currents');
    export_pdf_graphic(figure_L, '/measurements/inductance');
end



%% Functions

function I = current_model(b, x)

load("parameters_lagrangian.mat", "R10", "R20");
electromagnet_idx = evalin("base", "electromagnet_idx");

t = x(:, 1);
V = x(:, 2);
L = b(1);
R = (electromagnet_idx == 1) * R10 + (electromagnet_idx == 2) * R20;

I = V(end) / R - (V(end) - V(1)) / R * exp(-1 * R / L * t);

% Sanity checks for fitnlm stability
I(isinf(I)) = sign(x(isinf(I))) .* 1e100;
I(isnan(I)) = 1e100;

end

function L = inductance_model(b, x)

z = x(:, 1);
I = x(:, 2);

L0 = b(1);
az = b(2);
Lz = b(3);
aI = b(4);
bI = b(5);
LI = b(6);

% L = L0 + Lz * exp(-az * z);
L = L0 + Lz * exp(-az * z) + LI * atan(aI * I - bI);

% Sanity checks for fitnlm stability
L(isinf(L)) = sign(x(isinf(L))) .* 1e100;
L(isnan(L)) = 1e100;

end