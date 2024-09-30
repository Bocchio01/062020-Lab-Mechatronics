reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
% set(0, 'defaultaxesfontsize', 15);
% set(0, 'DefaultLineLineWidth', 2);

plot_struct.flags = true * [1];
plot_struct.export_path = ["latex/presentation/img/MATLAB"; "latex/report/img/MATLAB"];
plot_struct.data = cell(0);

if (plot_struct.flags(1))
    run("fig_01_undeformed_structure.m");
end

if (isfield(plot_struct, 'export_path'))
    for plot_idx = 1:numel(plot_struct.data)

        current_plot = plot_struct.data{plot_idx};
        tile = current_plot{1};
        local_path = current_plot{2};

        for path_idx = 1:length(plot_struct.export_path)
            filename = [plot_struct.export_path(path_idx) local_path '.png'];
            exportgraphics(tile, filename, 'Resolution', 300);
        end

    end
end

clear plot_struct plot_idx path_idx current_plot local_path filename tile 