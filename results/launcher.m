% clc
% clear variables
% close all

warning('off', 'MATLAB:print:ContentTypeImageSuggested');

%% Simulation name decode

test_labels = [
    "step"
    "multisteps_updown"
    "multisteps_stairs"
    "sinusoidal_slow"
    "sinusoidal_fast"
    "sinusoidal_slow_linear"
    ]';

controller_labels = [
    "*"
    "PID*"
    "LQ*"
    "MPC*"
    "PID_anti_windup"
    "PID_gain_scheduling"
    "LQR_classic"
    "LQR_tracking"
    "LQI"
    "MPC"
    ]';

filter_labels = [
    "*"
    "no_filter"
    "low_pass"
    "LO"
    "KF"
    "EKF"
    ]';


%% App launcher

app_results_selector(test_labels, controller_labels, filter_labels);