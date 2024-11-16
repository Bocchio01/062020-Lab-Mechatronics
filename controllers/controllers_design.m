clc
% clear variables
close all

run("initial_conditions.m")

% Ts = 0.005;

EM_number = 2;

%% Linearized state space representation

% assert(ismember(EM_number, [1 2]), 'Wrong number of electromagnets')

switch get_param("System/Plant (G)", "LabelModeActiveChoice")
% switch 'Literature model'

    case 'Literature model'
        [x_eq, u_eq] = operating_point_literature(z0);
        [A, B, C, D] = ABCD_literature(x_eq, u_eq);

    otherwise
        [x_eq, u_eq] = operating_point_lagrangian(z0);
        [A, B, C, D] = ABCD_lagrangian(x_eq, u_eq);

end

D = 0;
B = [0 0 B(3, 1) B(4, 2)]';

switch EM_number

    case 1
        A = A(1:3, 1:3);
        B = B(1:3, 1);
        C = C(1:3);
        D = D(1);

    case 2
        % Do nothing, ABCD_* already consider the complete 2EM model

end

% system = ss(A, B, C, D)
% disp(x_eq)
% disp(u_eq)


%% Transfer function of the plant (linearized)

[G_numerator, G_denominator] = ss2tf(A, B, C, D, 1);
G = tf(G_numerator, G_denominator);

system = ss(A, B, C, D);



%% PID

% controlSystemDesigner(G);

PID = pidtune(G, 'pid', 1/8 * (pi/1e-3));
% PID = pid(-825, -3.01e+03, -56.5);
% PID = pid(-314, -1.81e+03, -13.6);
% PID = pid(-1.17e+03, -3.42e+03, -99.4);


%% LQR

Q = diag([30 1e-3 1e+2 1e+2]);
R = diag([5.5 5.5]);

if (EM_number == 1)
    Q = Q(1:3, 1:3);
    R = R(1:1, 1:1);
end

R = 5.5;

LQR = lqr(A, B, Q, R);
LQR = [LQR; zeros(1, 4)];

if (EM_number == 1)
    LQR = [LQR 0; zeros(1, 4)];
end


%% MPC

% mpcDesigner(G);
% mpcDesigner('controllers/sessions/MPC_designer_session.mat');
% mpcobj = mpc(G, Ts);


%% KF
% 
% Q = 1e-10;
% R = 1e-10;
% 
% [K_KF, L_KF, P_KF] = kalman(system, Q, R);