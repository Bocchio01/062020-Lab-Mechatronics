function figure_stability = plots_for_stability(R, G, name_of_controller)

L = series(R, G);
current_poles = rlocus(L(:, :, 1), 1);

Pool = {'false', 'true'};
disp([name_of_controller ' is stable: ' Pool{isstable(feedback(L, 1)) + 1}])
disp('eig(A):')
disp(current_poles)

figure_stability = figure('Name', name_of_controller);


% Bode plots of L
subplot(2, 2, [1 3])
if(size(L) == 1)
    % asymp(L)
    margin(L)
else
    bode(L)
end
grid on


% Root locus of L (not G!)
subplot(2, 2, 2)
hold on
rlocus(L)
plot(real(current_poles), imag(current_poles), 'rx', 'Markersize', 10)
ylim([-80 80])


% Step of the feedback (closed) loop (L/(1+L))
subplot(2, 2, 4)
step(feedback(L, 1))
grid on

end

