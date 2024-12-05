clc
clear variables
close all

%% Load measurements and use window to split into many data set

electromagnet_idx = 1;

measurements = load('identification\data\sensor\noises.mat').measurements;

windows_count = 10;
windows_length = floor(size(measurements, 2) / windows_count);

data = repmat( ...
    struct( ...
    'time', [], ...
    'position', [], ...
    'velocity', [], ...
    'current', [], ...
    'control', [], ...
    'voltage', []), ...
    1, ...
    windows_count);

for windows_idx = 1:windows_count
    
    idxs = windows_length*(windows_idx-1)+1 : windows_length*windows_idx;

    data(windows_idx).time = measurements(1, idxs)';
    data(windows_idx).position = measurements(2, idxs)';
    data(windows_idx).velocity = measurements(3, idxs)';
    data(windows_idx).current = measurements(3 + electromagnet_idx, idxs)';
    data(windows_idx).control = measurements(5 + electromagnet_idx, idxs)';

    data(windows_idx).voltage = U_to_V(data(windows_idx).control);

end

clear idxs measurements


%% Noise analysis

standard_deviation_vector = zeros(windows_count, 2);
variance_vector = zeros(windows_count, 2);
covariance_vector = zeros(windows_count, 2);

for windows_idx = 1:windows_count

    standard_deviation_vector(windows_idx, :) = std([data(windows_idx).position data(windows_idx).current]);
    variance_vector(windows_idx, :) = [var(data(windows_idx).position) var(data(windows_idx).current)];
    covariance_vector(windows_idx, :) = [cov(data(windows_idx).position) cov(data(windows_idx).current)];
    
end


%% Results

fprintf([ ...
    'Sensor noise characterization:\n' ...
    '\tCovariance z:\t%d\n' ...
    '\tCovariance I%d:\t%d\n' ...
    '\tStandard deviation z:\t%d\n' ...
    '\tStandard deviation I%d:\t%d\n' ...
    ], mean(covariance_vector(:, 1)), electromagnet_idx, mean(covariance_vector(:, 2)), ...
    mean(standard_deviation_vector(:, 1)), electromagnet_idx, mean(standard_deviation_vector(:, 2)));


%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure_statistical = figure('Name', 'Statistical indicators');
tile = tiledlayout(2, 5);

nexttile(tile, 1, [1, 4]);
hold on
grid on

for windows_idx = 1:windows_count
    plot((data(windows_idx).position - mean(data(windows_idx).position)) * 1e3, '-o')
end

xlim tight
title('Position records')
xlabel('# []')
ylabel('Variation [mm]')


nexttile(tile, 6, [1, 4]);
hold on
grid on

for windows_idx = 1:windows_count
    plot(data(windows_idx).current - mean(data(windows_idx).current), '-')
end

xlim tight
title('Current records')
xlabel('# [-]')
ylabel('Variation [A]')


nexttile
hold on
grid on

y_vector = -0.05:0.001:0.05;

plot(normpdf(y_vector, 0, mean(standard_deviation_vector(:, 1))), y_vector, '--k', 'LineWidth', 2)
for windows_idx = 1:windows_count
    plot(normpdf(y_vector, 0, standard_deviation_vector(windows_idx, 1)), y_vector)
end

title('Noise distribution (position)')

nexttile
hold on
grid on

y_vector = -0.05:0.001:0.05;

plot(normpdf(y_vector, 0, mean(standard_deviation_vector(:, 2))), y_vector, '--k', 'LineWidth', 2)
for windows_idx = 1:windows_count
    plot(normpdf(y_vector, 0, standard_deviation_vector(windows_idx, 2)), y_vector)
end

title('Noise distribution (current)')

try %#ok<TRYNC>
    % export_pdf_graphic(figure_statistical, '/identification/sensor_noises');
end