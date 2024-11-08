% Modelling and control of a Magnetic Levitation System
%
% This project explores traditional and modern control theory techniques 
% to stabilize the position of a ferromagnetic ball suspended in a magnetic 
% field produced by two inductors.
% A "Model-based design" (MBD) approach has been adopted.
%
% Author =  Tommaso Bocchietti, Daniele Cianca, Sara Orazzo
% Date =  00/00/2024
%
% Requires = 
%   - Simulink
%   - Coder Toolbox
%   - INTECO MSL2EM Toolbox (licensed from the producer)
% 
% Reference course =  062020 (Politecnico di Milano A.Y. 2024/2025)

clc
clear variables
close all

%% Simulation parameters

run("initial_conditions_init.m")
run("maglev_init.m")

[x_eq, u_eq] = literature_operating_point(z0);


%% Controllers tuning


%% Controller labels

controller_labels = [
    % "LQR tracking"
    % "MCP"
    "PID"
    % "PID and LQR"
    "PID anti-windup"
    % "PID cascade"
    % "PID gain scheduling"
];


%% Simulation launcher

model_name = "System";
timeout = 5;

in = Simulink.SimulationInput("System");
in = in.setModelParameter("SimulationMode", "normal");
% in = in.setModelParameter("SimulationMode", "external"); % Not supported

for controller_idx = 1:length(controller_labels)

    in = in.setBlockParameter("System/Controller (K)", "LabelModeActiveChoice", controller_labels(controller_idx));
    out = sim(in);
    % in = in.setModelParameter("SimulationCommand", "start");

    % tic;
    % while(true)
    %     if not(strcmpi(in.getModelParameter("SimulationStatus"), 'running'))
    %         disp('simulation exited')
    %         break;
    %     end
    %     if toc>=timeout
    %         disp('timout reached')
    %         in.setModelParameter("SimulationCommand", "stop");
    %         break;
    %     end
    %     pause(1);
    % end
    
    status = copyfile("runs\_simout.mat", ['runs\randomic\st_' char(controller_labels(controller_idx)) '.mat']);
    assert(status == 1, 'Error while moving the _simout.mat file')

end

%%

nexttile
hold on
grid on

run("maglev_init.m")

I = @(z) -(0.4/0.02) * z + 0.4;
L = @(z, I) L10 + L1z * exp(-a1z * z) + L1I * atan(a1I * I - b1I);

fplot(@(x) L(x, I(x)), [0 2e-2]);
fplot(@(x) R10 * fiP1 / fiP2 * exp(-x / fiP2), [0 2e-2]);

legend('Theoretical', 'Approximated')