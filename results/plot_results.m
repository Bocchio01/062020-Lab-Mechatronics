function figure_results = plot_results(simouts)

is_single_controller = size(simouts, 1) == 1;
% is_single_controller = 1;

% Plots settings
reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultLineLineWidth', 1.2);
set(0, 'defaultaxesfontsize', 12);

figure_results = figure('Name', 'Results analysis');
colorscheme = get(gca, 'ColorOrder');
tiles = tiledlayout(2, 1 * not(is_single_controller) + 2 * (is_single_controller), ...
    'TileSpacing', 'tight', 'Padding', 'compact');


%% Common data

simout = simouts{1, 1};

time = simout(1, :)';
ref = simout(2, :)';

% Position data
position_tile = nexttile(tiles, 1);
hold on
grid on

plot(time, ref * 1000, 'Color', [0, 0, 0, 0.5], 'LineWidth', 1, 'DisplayName', 'Reference')

ylim([0.9*min(ref) 1.1*max(ref)]*1000)
set(gca, 'YDir', 'reverse')

title('Position data')
xlabel('Time [s]')
ylabel('Position [mm]')
legend('Location', 'best')


if is_single_controller

    % Velocity data
    velocity_tile = nexttile(tiles, 2);
    hold on
    grid on

    ylim([-30 50])

    title('Velocity data')
    xlabel('Time [s]')
    ylabel('Velocity [mm/s]')
    legend()

    % Coils data
    coils_tile = nexttile(tiles, 3);
    hold on
    grid on

    ylim([0.75 1.25])

    title('Coils data')
    xlabel('Time [s]')
    ylabel('Current [A]')
    legend()

end

% Controls data
controls_tile = nexttile(tiles, 2 * not(is_single_controller) + 4 * (is_single_controller));
hold on
grid on

ylim([0 100])
ytickformat('percentage')

title('Controls data')
xlabel('Time [s]')
ylabel('PWM [%]')
legend()


if is_single_controller
    linkaxes([position_tile velocity_tile coils_tile controls_tile], 'x')
else
    linkaxes([position_tile controls_tile], 'x')
end

if sum(diff(ref(1:end-1)) ~= 0) == 1
    % Single step case
    xlim([4.5 7.5])
else
    % Multiple step or sine cases
    xlim([5 13.5])
end


%% Loop over all simulations

for simout_idx = 1:size(simouts, 1)
    legend_name = erase(string(simouts{simout_idx, 2}), '.mat');
    legend_name = replace(legend_name , '_', '-');

    % if (contains(legend_name, 'LO'))
    %     continue
    % end
    % if (contains(legend_name, 'filter'))
    %     continue
    % end

    simout = simouts{simout_idx, 1};

    time = simout(1, :)';

    U1 = simout(7, :)';
    z_hat = simout(9, :)';
    v_hat = simout(10, :)';
    I1_hat = simout(11, :)';

    if (contains(legend_name, 'PID'))
        v_hat = v_hat + sqrt(1e-04) * randn(length(v_hat), 1);
    end

    alpha = 0.5 * not(is_single_controller) + 1 * (is_single_controller);

    % Position data
    nexttile(tiles, 1);
    plot(time, z_hat * 1000, 'Color', [colorscheme(mod(simout_idx, size(colorscheme, 1)), :) 1], 'DisplayName', legend_name)

    if is_single_controller

        % Velocity data
        nexttile(tiles, 2);
        plot(time, v_hat * 1000, 'Color', [colorscheme(mod(simout_idx, size(colorscheme, 1)), :) alpha], 'DisplayName', legend_name)
        

        % Coils data
        nexttile(tiles, 3);
        plot(time, I1_hat, 'Color', [colorscheme(mod(simout_idx, size(colorscheme, 1)), :) alpha], 'DisplayName', legend_name)

    end

    % Controls data
    nexttile(tiles, 2 * not(is_single_controller) + 4 * (is_single_controller));

    % if (contains(legend_name, 'PID'))
    %     time = time(1:7500);
    %     U1 = U1(1:7500);
    % end
    % 
    % if (contains(legend_name, 'LQ'))
    %     time = time(7500:10500);
    %     U1 = U1(7500:10500);
    % end
    % 
    % if (contains(legend_name, 'MPC'))
    %     time = time(10500:end);
    %     U1 = U1(10500:end);
    % end

    plot(time, 100*U1, 'Color', [colorscheme(mod(simout_idx, size(colorscheme, 1)), :) alpha], 'DisplayName', legend_name)

end

end

