% Modelling and control of a Magnetic Levitation System
%
% This project explores traditional and modern control theory techniques 
% to stabilize the position of a ferromagnetic ball suspended in a magnetic 
% field produced by two inductors.
% A "Model-based design" (MBD) approach has been adopted.
%
% Author: Tommaso Bocchietti, Daniele Cianca, Sara Orazzo
% Date: 00/00/2024
%
% Requires:
%   - Simulink
%   - Coder Toolbox
%   - INTECO MSL2EM Toolbox (licensed from the producer)
% 
% Reference course: 062020 (Politecnico di Milano A.Y. 2024/2025)

clc
clear variables
close all

%% Simulation parameters

run("initial_conditions.m")

%% Simulation launcher

sim("System.slx")