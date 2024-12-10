clc
clear variables
close all

%% Controller labels

controller_labels = [
    "PID classical"
    "PID anti-windup"
    "PID cascade"
    "PID gain scheduling"
    "LQR classical"
    "LQR tracking"
    "LQI classical"
    "LQG classical"
    % "MCP"
    ]';


%% Simulation launcher

model = Simulink.SimulationInput("System");
model = model.setModelParameter("SimulationMode", "normal");
model = model.setModelParameter("SolverType", "Variable-step");
model = model.setModelParameter("StopTime", "4");
% slbuild(model)

for controller_label = controller_labels
    
    model_with_controller = model.setBlockParameter("System/Controller (K)", "LabelModeActiveChoice", controller_label);

    out = sim([
        model_with_controller.setBlockParameter("System/Plant (G)", "LabelModeActiveChoice", "Literature model");
        model_with_controller.setBlockParameter("System/Plant (G)", "LabelModeActiveChoice", "Lagrangian model");
        ]);

    % out.ErrorMessage

    try %#ok<TRYNC>
        movefile("results\_simout_1.mat", strcat("results\step\literature_", replace(controller_label, ' ', '_'), ".mat"))
        movefile("results\_simout_2.mat", strcat("results\step\lagrangian_", replace(controller_label, ' ', '_'), ".mat"))
    end

end