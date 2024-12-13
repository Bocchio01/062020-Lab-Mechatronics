% clc
% clear variables
% close all

%% Force model

load("parameters_lagrangian.mat", "L1z", "a1z", "m", "g");

F = @(z, I) abs(-1/2 * a1z * L1z * exp(-a1z * z) .* I.^2);

z_vector = linspace(0, 0.022, 50);
I_vector = linspace(0, 2.66, 50);

[Z_grid, I_grid] = meshgrid(z_vector, I_vector);
force_field = F(Z_grid, I_grid);
M = contourc(z_vector, I_vector, force_field, [m*g m*g]);


%% Results

fprintf('Maximum reachable distance:\t%d [mm]\n', max(M(1, :) * 1e3))


%% Plots

figure('Name', 'Levitation region analysis')
hold on
grid on
set(gca, 'layer', 'top')
set(gca().XAxis, 'TickValues', 0:2:22, 'MinorTick', 'on', 'MinorTickValues', 0:2:100);

s = pcolor(z_vector * 1000, I_vector, F(Z_grid, I_grid));
s.FaceColor = 'interp';
s.EdgeColor = 'none';

colormap([1 1 1; colormap(jet(64))]);
clim([0.5*m*g max(force_field, [], 'all')]);

cb = colorbar(); 
ylabel(cb, 'F (N)')

xlim([0 ceil(max(M(1, 2:end) * 1e3))])
ylim([floor(min(M(2, 2:end) * 1e1))*1e-1 2.5])
title('Levitation region')
xlabel('z [mm]')
ylabel('I [A]')


try %#ok<TRYNC>
    export_pdf_graphic(gcf, '/analysis/levitation_region');
end
