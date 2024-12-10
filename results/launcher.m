clc
clear variables
close all

warning('off', 'MATLAB:print:ContentTypeImageSuggested');

%% Simulation name decode

test_labels = [
    "step"
    "multisteps_updown"
    "multisteps_stairs"
    "sinusoidal_slow"
    "sinusoidal_fast"
    ]';

controller_labels = [
    "*"
    % "PID_classical"
    "PID_anti_windup"
    "PID_cascade"
    "PID_gain_scheduling"
    "LQR_classical"
    "LQR_tracking"
    "LQI"
    "LQG_classical"
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