% Load results
simouts = cell(1, 2);

simouts{1, 1} = load('results\multisteps_updown\LQR_tracking - KF.mat').logouts;
simouts{1, 2} = 'LQR_tracking - KF';

simouts{1, 1}(1, :) = simouts{1, 1}(1, :) + 2;

plot_results(simouts);