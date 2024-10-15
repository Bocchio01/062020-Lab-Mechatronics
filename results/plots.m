
% logsout = load("results\simulations\");

r_obj = logsout.get("r");
z_obj = logsout.get("z");
v_obj = logsout.get("v");
I1_obj = logsout.get("I1");
I2_obj = logsout.get("I2");
V1_obj = logsout.get("V1");
V2_obj = logsout.get("V2");


%% Plots
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');

figure('Name', 'Results analysis')
t = tiledlayout(2, 3);


% Position data
position_tile = nexttile(t, 1, [1 3]);
hold on
grid on

plot(r_obj.Values.Time, r_obj.Values.Data * 1e+3, '--k', 'LineWidth', 1)
plot(z_obj.Values.Time, z_obj.Values.Data * 1e+3, 'r', 'LineWidth', 1)

set(gca, 'YDir', 'reverse')

title('Position data')
xlabel('Time [s]')
ylabel('Vertical position [mm]')
legend('Reference position', 'Ball position')


% Velocity data
velocity_tile = nexttile;
hold on
grid on

plot(v_obj.Values.Time, -v_obj.Values.Data * 1e+3)

% set(gca, 'YDir', 'reverse')

title('Velocity data')
xlabel('Time [s]')
ylabel('Vertical position [mm/s]')
legend('Ball velocity')


% Coils data
coils_tile = nexttile;
hold on
grid on

plot(I1_obj.Values.Time, I1_obj.Values.Data)
plot(I2_obj.Values.Time, I2_obj.Values.Data)

title('Coils data')
xlabel('Time [s]')
ylabel('Current [A]')
legend('Coil_1 current', 'Coil_2 current')


% Controls data
controls_tile = nexttile;
hold on
grid on

plot(V1_obj.Values.Time, V1_obj.Values.Data)
plot(V2_obj.Values.Time, V2_obj.Values.Data)

title('Controls data')
xlabel('Time [s]')
ylabel('Voltage [V]')
legend('Coil_1 control voltage', 'Coil_2 control voltage')


linkaxes([position_tile velocity_tile coils_tile controls_tile], 'x')
xlim tight