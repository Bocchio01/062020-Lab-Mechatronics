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

%% Controller labels

controller_labels = [
    % "LQR tracking"
    % "MCP"
    "PID"
    % "PID and LQR"
    "PID anti-windup"
    % "PID cascade"
    % "PID gain scheduling"
    ]';


%% Simulation launcher

model = Simulink.SimulationInput("System");
model = model.setModelParameter("SimulationMode", "normal");

for controller_label = controller_labels
    
    model_with_controller = model.setBlockParameter("System/Controller (K)", "LabelModeActiveChoice", controller_label);

    out = sim([
        % model_with_controller.setBlockParameter("System/Plant (G)", "LabelModeActiveChoice", "Literature model");
        model_with_controller.setBlockParameter("System/Plant (G)", "LabelModeActiveChoice", "Lagrangian model");
        ]);

end