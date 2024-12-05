clc
clear variables
close all

run("initial_conditions.m")
run("controllers_design.m")

L = series(1, G);

%% Stability analysis

% Eigenvalue of A
[A_eigenvectors, A_eigenvalues] = eig(A);
A_eigenvalues = diag(A_eigenvalues);

if all(real(A_eigenvalues) < 0), disp('The system is stable.');
elseif any(real(A_eigenvalues) > 0), disp('The system is unstable.');
else, disp('The system has marginal stability.');
end

% Controllability
KR = ctrb(A, B);

if rank(KR) == size(A, 1), disp('The system is controllable.');
else, disp('The system is NOT controllable.');
end

% Observability
KO = obsv(A, C);

if rank(KO) == size(A, 1), disp('The system is observable.');
else, disp('The system is NOT observable.');
end

% Margins for G
[Gain_margin, Phase_margin, Phase_crossover_frequency, Gain_crossover_frequency] = margin(L)

% Bandwidth for G (?)
disp(['System Bandwidth: ' num2str(bandwidth(L)) ' rad/s']);



%% Plots

reset(0)
set(0, 'DefaultFigureNumberTitle', 'off');
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'defaultaxesfontsize', 15);


% Root Locus
figure('Name', 'Root locus')

root_locus_direct = rlocus(G);
title('Root locus (Direct)')

root_locus_inverse = rlocus(-G);
title('Root locus (Inverse)')

% Pole and Zeros map
pole_zero_map = pzplot(G);
grid on

% Bode Plot
asymp(L)

% System Response
% subplot(2, 2, 4)
% step(feedback(L, 1))
% grid on
% title('Unit step response')


try %#ok<TRYNC>
    % export_pdf_graphic(root_locus_direct, '/analysis/root_locus_direct')
    % export_pdf_graphic(root_locus_inverse, '/analysis/root_locus_inverse')
    % export_pdf_graphic(pole_zero_map, '/analysis/pole_zero_map')
    % export_pdf_graphic(gcf, '/analysis/bode_plot')
end