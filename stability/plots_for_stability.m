function figure_stability = plots_for_stability(R, G, name_of_controller)

L = series(R, G);
current_poles = rlocus(L(:, :, 1), 1);

Pool = {'false', 'true'};
disp([name_of_controller ' is stable: ' Pool{isstable(feedback(L, 1)) + 1}])
disp('eig(A):')
disp(current_poles)

figure_stability = figure('Name', name_of_controller);


% Bode plots of L
subplot(2, 3, [1 4])
if(size(L) == 1)
    % asymp(L)
    margin(L)
else
    bode(L)
end
grid on


% Root locus of L (not G!)
subplot(2, 3, 2)
hold on
plot(real(current_poles), imag(current_poles), 'kx', 'Markersize', 15)
rlocus(L)
legend('Current poles')

% Root locus of L (not G!)
subplot(2, 3, 3)
hold on
plot(real(current_poles), imag(current_poles), 'kx', 'Markersize', 15)
rlocus(L)
xlim([-22 12])
ylim([-20 20])
legend('Current poles')


% Step of the feedback (closed) loop (L/(1+L))
subplot(2, 3, [5 6])
step(feedback(L, 1))
grid on

end

