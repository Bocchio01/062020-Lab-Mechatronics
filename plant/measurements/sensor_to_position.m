% clc
% clear variables
close all

%% Load data

inteco_sensor_data = load('plant\measurements\data\mls2em_usb2_sensor.mat').SensorData;
sensor_data = load('plant\measurements\data\sensor_data.mat').SensorData;


%% Plots

nexttile
hold on
grid on

plot(inteco_sensor_data.Sensor_V, inteco_sensor_data.Distance_mm);
plot(sensor_data.Sensor_V, sensor_data.Distance_mm);
plot(sensor_data.Sensor_V - 0.65, sensor_data.Distance_mm);

title('Optical sensor characterization')
xlabel('Voltage [V]')
ylabel('Ball position [mm]')
legend('Inteco', 'Our', 'Corrected')
