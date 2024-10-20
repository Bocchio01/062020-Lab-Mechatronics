clc
clear variables
close all

%% Load measurements of RL current dynamic

file_path = 'plant\measurements\data\MinControl.mat';

electromagnet_idx = 2;
data = load_data(file_path, electromagnet_idx);


%% Compute (mean) min current 

minCurrent = mean(data.current);

fprintf([ ...
    'Electromagnet EM%d:\n' ...
    '\tMinCurrent ci:\t%d\n' ...
    ], electromagnet_idx, minCurrent);
