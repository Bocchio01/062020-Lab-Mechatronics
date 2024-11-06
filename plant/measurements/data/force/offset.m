% clc
% clear variables
% close all

%% Load data

files_data = struct( ...
    'path', 'plant\measurements\data\force', ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path '\*.mat']);
files_data.dir_content = files_data.dir_content(1:end-1);
files_data.N_files = length(files_data.dir_content);

inteco_sensor_data = load('plant\measurements\data\mls2em_usb2_sensor.mat').SensorData;
sensor_data = load('plant\measurements\data\sensor_data.mat').SensorData;


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
    data = load_data([files_data.path '\' files_data.dir_content(file_idx).name]);

    sensor_voltage = interp1(sensor_data.Distance_m, sensor_data.Sensor_V, data.position);
    data.position = interp1(sensor_data.Sensor_V - 0.65, sensor_data.Distance_m, sensor_voltage);
    data.position(isnan(data.position)) = rand(sum(isnan(data.position)), 1) * 1e-7;

end

clear file_idx