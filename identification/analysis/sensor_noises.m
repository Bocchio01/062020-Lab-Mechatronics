clc
clear variables
close all

%% Get number of files to be loaded

electromagnet_idx = 1;
file_path = 'identification\data\inductance';

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


%% Noise analysis

Fs = 1 / 0.001;

position_mean = zeros(files_data.N_files, 1);
position_variance = zeros(files_data.N_files, 1);
position_standard_deviation = zeros(files_data.N_files, 1);
Hpsd = cell(files_data.N_files, 1);
Hmss = cell(files_data.N_files, 1);

for file_idx = 1:files_data.N_files

    measurements = data(file_idx);
    [position_variance(file_idx), position_mean(file_idx)] = var(measurements.position);

    Hpsd{file_idx} = dspdata.psd(measurements.position);
    Hmss{file_idx} = dspdata.msspectrum( ...
        periodogram((measurements.position - position_mean(file_idx)), [], [], Fs), ...
        'Fs', Fs, ...
        'spectrumtype', 'onesided');
    
end

position_standard_deviation(:) = sqrt(position_variance);



%% Plots
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure('Name', 'Mean and variance')

nexttile
hold on
grid on

plot(position_mean, position_variance)

title('Sensor Variance')
xlabel('Position [mm]')
ylabel('Variance [mm^2]')

nexttile
hold on
grid on

plot(position_mean, position_standard_deviation)

title('Sensor Standard Deviation')
xlabel('Position [mm]')
ylabel('Standard Deviation [mm]')


figure('Name', 'Mean-square spectrum')
hold on
grid on

for file_idx = 1:files_data.N_files

    plot(Hmss{file_idx})
    
end


figure('Name', 'Mean-square spectrum')
hold on
grid on

for file_idx = 1:files_data.N_files

    plot(Hpsd{file_idx})
    
end

