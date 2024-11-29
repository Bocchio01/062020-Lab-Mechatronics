clc
clear variables
close all

%% Get number of files to be loaded

electromagnet_idx = 1;
sensor_considered = 'position'; 
sensor_considered = 'current';
file_path = 'identification\data\current_minimum';

files_data = struct( ...
    'path', file_path, ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\' '*.mat']);
% files_data.dir_content(10) = [];
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


%% Noise analysis

Fs = 1 / 0.001;

mean_vector = zeros(files_data.N_files, 1);
variance_vector = zeros(files_data.N_files, 1);
standard_deviation_vector = zeros(files_data.N_files, 1);
covariance_vector = zeros(files_data.N_files, 1);
psd_vector = cell(files_data.N_files, 1);

for file_idx = 1:files_data.N_files

    measurements = ...
        strcmp(sensor_considered, 'position') * data(file_idx).position + ...
        strcmp(sensor_considered, 'current') * data(file_idx).current; 

    [variance_vector(file_idx), mean_vector(file_idx)] = var(measurements);
    covariance_vector(file_idx) = cov(measurements);
    psd_vector{file_idx} = pwelch(measurements);
    
end

standard_deviation_vector(:) = sqrt(variance_vector);


%% Results

fprintf([ ...
    'Sensor noise characterization (%s):\n' ...
    '\tCovariance:\t%d\n' ...
    ], sensor_considered, mean(covariance_vector));


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure('Name', 'Statistical indicators')

nexttile
hold on
grid on

plot(mean_vector, variance_vector, 'o')

title('Sensor Variance')
switch sensor_considered
    case 'position'
        xlabel('Position [mm]')
        ylabel('Variance \sigma [mm^2]')
    case 'current'
        xlabel('Current [A]')
        ylabel('Variance \sigma [A^2]')
end


nexttile
hold on
grid on

x_vector = -0.05:0.001:0.05;

plot(x_vector, normpdf(x_vector, 0, mean(standard_deviation_vector)), 'k', 'LineWidth', 3)
plot(x_vector, normpdf(x_vector, 0, standard_deviation_vector))

title('Sensor Standard Deviation')
switch sensor_considered
    case 'position'
        xlabel('Position [mm]')
        ylabel('Standard Deviation [mm]')
    case 'current'
        xlabel('Current [A]')
        ylabel('Standard Deviation [A]')
end


nexttile
hold on
grid on

plot(mean_vector, covariance_vector, 'o')

title('Sensor Covariance')
switch sensor_considered
    case 'position'
        xlabel('Position [mm]')
        ylabel('Variance \sigma [mm^2]')
    case 'current'
        xlabel('Current [A]')
        ylabel('Variance \sigma [A^2]')
end


figure('Name', 'Power Spectral Density')
hold on
grid on
yscale log

for file_idx = 1:files_data.N_files
    plot(psd_vector{file_idx})
end