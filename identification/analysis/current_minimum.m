clc
clear variables
close all

%% Load measurements of RL current dynamic

file_path = 'plant\measurements\data\control\minimum_current.mat';

I_min = zeros(2, 1);

for electromagnet_idx = 1:length(I_min)

    data = load_data(file_path, electromagnet_idx);

    I_min(electromagnet_idx) = mean(data.current);

end

fprintf([ ...
    'Minimum currents:\n' ...
    '\tI1min:\t%d\n' ...
    '\tI2min:\t%d\n' ...
    ], I_min(1), I_min(2));
