try
    simout = load("runs\_simout.mat").logouts;
catch
    uiopen('load');
    simout = logouts;
end

time = simout(1, :)';
z = simout(2, :)';
v = simout(3, :)';
I1 = simout(4, :)';
I2 = simout(5, :)';
U1 = simout(6, :)';
U2 = simout(7, :)';
ref = simout(8, :)';


%% Plots
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);

figure_plots = figure('Name', 'Results analysis');
t = tiledlayout(3, 1);


% Position data
position_tile = nexttile(t);
hold on
grid on

plot(time, z * 1000, 'LineWidth', 1)
plot(time, ref * 1000, 'k--', 'LineWidth', 1)

set(gca, 'YDir', 'reverse')

title('Position data')
xlabel('Time [s]')
ylabel('Position [mm]')
legend('Ball position', 'Reference position')


% Velocity data
% velocity_tile = nexttile;
% hold on
% grid on
% 
% plot(time, v * 1000)
% 
% title('Velocity data')
% xlabel('Time [s]')
% ylabel('Velocity [mm/s]')
% legend('Ball velocity')


% Coils data
coils_tile = nexttile;
hold on
grid on

plot(time, I1)
plot(time, I2)

title('Coils data')
xlabel('Time [s]')
ylabel('Current [A]')
legend('I1', 'I2')


% Controls data
controls_tile = nexttile;
hold on
grid on

plot(time, U1)
plot(time, U2)

a = [cellstr(num2str((0:0.1:1)' * 100))]; 
pct = char(ones(size(a, 1), 1) * '%'); 
set(gca, 'yticklabel', [char(a), pct])

title('Controls data')
xlabel('Time [s]')
ylabel('PWM [%]')
legend('U1', 'U2')


linkaxes([position_tile velocity_tile coils_tile controls_tile], 'x')
xlim tight

export_pdf_graphic(figure_plots, '/runs/tmp')