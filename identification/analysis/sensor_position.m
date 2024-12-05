clc
clear variables
close all

%% Load data

sensor_data = load('sensor_data.mat').SensorData;


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultAxesFontSize', 15);

figure_sensor_position = figure('Name', 'Sensor to position');

nexttile
hold on
grid on

plot(sensor_data.Sensor_V, sensor_data.Distance_m * 1e3, '-o');

title('Optical sensor characterization')
xlabel('Sensor output voltage [V]')
ylabel('Ball position [mm]')
legend('Measured data')

try %#ok<TRYNC>
    export_pdf_graphic(figure_sensor_position, '/identification/sensor_position')
end
