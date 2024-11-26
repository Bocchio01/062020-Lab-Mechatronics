clc
clear variables
close all

%% Load data

inteco_sensor_data = load('mls2em_usb2_sensor.mat').SensorData;
sensor_data = load('sensor_data.mat').SensorData;


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultAxesFontSize', 15);

figure('Name', 'Sensor to position')
tile = nexttile;
hold on
grid on

plot(sensor_data.Distance_mm, sensor_data.Sensor_V);
plot(inteco_sensor_data.Distance_mm, inteco_sensor_data.Sensor_V);

title('Optical sensor characterization')
xlabel('Ball position [mm]')
ylabel('Voltage [V]')
legend('Experimental data', 'Inteco manual')

export_pdf_graphic(tile, '/identification/sensor_position')

