clc
clear variables
close all

opts.Interpreter = 'none';
opts.Default = 'No';
answer = questdlg('You are going to modify test dataset. Do you want to proceed?', 'Irreversible action', opts);
assert(strcmp(answer, 'Yes'), 'Script interrupted')

%% Load data

files_data = struct( ...
    'path', 'plant\measurements\data\force', ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\*.mat']);
files_data.dir_content = files_data.dir_content(1:end-1);
files_data.N_files = length(files_data.dir_content);

sensor_data = load('plant\measurements\data\sensor_data.mat').SensorData;


%% Perform offset correction and save

for file_idx = 1:files_data.N_files

    measurements = load([files_data.path '\' files_data.dir_content(file_idx).name]).measurements;

    sensor_voltage = interp1(sensor_data.Distance_m, sensor_data.Sensor_V, measurements(2, :));
    measurements(2, :) = interp1(sensor_data.Sensor_V - 0.65, sensor_data.Distance_m, sensor_voltage);
    measurements(2, isnan(measurements(2, :))) = rand(sum(isnan(measurements(2, :))), 1) * 1e-7;

    save([files_data.path '\' files_data.dir_content(file_idx).name], 'measurements');

end

clear file_idx