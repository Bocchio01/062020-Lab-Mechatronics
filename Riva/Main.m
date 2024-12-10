%%
% KBF
% Mechatronic systems and Lab. 
% Example N°1
% Riva Emanuele ** emanuele.riva@polimi.it **

clear 
close all
clc

% Data of the pendulum
g = 9.81; % [m/s^2] gravity
L = 0.1; % [m] length of the pendulum
w0 = sqrt(g/L);
zeta = 0.02;
m = 1;

% weight on the control action
R = 1;

% weight on the state
Q = zeros(2);
Q(1,1) = 1;
Q(2,2) = 1;

% Normalization variables
dQpMax = 1000;          %[rad/s]
dQMax = 1;              %[rad]
dCMax = 1;              %[Nm]

Q(1,1) = Q(1,1)./dQpMax.^2;
Q(2,2) = Q(2,2)./dQMax.^2;

R = R./dCMax.^2;

% Final target - REFERENCE POSITION
th_f = pi/4;
thp_f = 0;
x_f = [thp_f; th_f];
u_f = w0^2*cos(th_f)*m*L^2;

% Jacobian of the dynamics
fx = @(x,u) [ - 2*zeta*w0, - w0^2*cos(x(1));
                        1,               0];
fu = @(x,u) [ 1/m/L^2; 0];

%% LQR @(Es 2) Infinite time control around the final equilibrium position

% Stability and Control matrix
A = fx(x_f,u_f);
B = fu(x_f,u_f);
C = zeros(1,2);
C(1,2) = 1;
D = zeros(2);

% Poles of the uncontrolled system
PolesUC = eig(A);

% Gain matrix and Poles of the controlled system
[K,PP,PolesC] = lqr(A,B,Q,R);

%% DATA FOR THE KALMAN FILTER

% how much the system model is reliable?
Qk = zeros(2);
Qk(1,1) = 1;
Qk(2,2) = 1;

% how much the measurements are reliable?
Rk = 0.1;

%% OPTIMAL OBSERVER DESIGN

[~,~,Ko] = care(A',C',Qk,Rk);
Ko = Ko';

PolesOBS = eig(A'-C'*Ko');

% [~,Ko,~] = icare(A',C',Qk,Rk);
% Ko = Ko';

%% PLOT OF THE OBSERVER AND SYSYEM POLES

FigTag = figure;
ax = axes;
hold on; grid on; box on;
plot(real(PolesUC),imag(PolesUC),'x','LineWidth',2,'color','b');
plot(real(PolesC),imag(PolesC),'x','LineWidth',2,'color','r');
plot(real(PolesOBS),imag(PolesOBS),'x','LineWidth',2,'color','k');
xlabel('$\Re\{\omega\}$ [rad/s]','Interpreter','LaTex')
ylabel('$\Im\{\omega\}$ [rad/s]','Interpreter','LaTex')
legend({'Uncontrolled','Controlled','Observer'},'Interpreter','LaTex','Location','Best')
ax.FontSize = 16;
ax.TickLabelInterpreter = 'LaTex';

% print(FigTag,'figA.jpeg','-djpeg','-r600')

%% Simulink Model

% % data for the simulink environment
% IC = x_f';
% ICobs = [0,0.05];
% Wamp = 1*10^-4;
% Namp = 2*10^-2;
% Tamp = 5*10^-3;
% Wfreq = 10;      %[Hz]
% Tfreq = 10;      %[Hz]
% Tf = 2;        %[s]
% 
% sim('Sim_exe.slx')
% 
% Xs = squeeze(Xs.data);
% Xobs = squeeze(Xobs.data);
% U = squeeze(U.data);
% Uopt = squeeze(Uopt.data);
% time = squeeze(time.data);
% Xref = squeeze(Xref.data);
% 
% % neighboring observed quantities + control action
% FigTag = figure;
% ax = axes;
% plot(time,Xobs(:,1),'LineWidth',1,'LineStyle','-','color','b');
% hold on; grid on; box on;
% plot(time,Xobs(:,2),'LineWidth',1,'LineStyle','-','color','r');
% xlabel('t [s]','Interpreter','LaTex')
% ylabel('$\delta\dot\theta,\;\delta\theta$','Interpreter','LaTex')
% ax.FontSize = 16;
% ax.TickLabelInterpreter = 'LaTex';
% legend({'$\delta\dot\theta$','$\delta\theta$'},'Interpreter','LaTex','Location','northeast')
% 
% % print(FigTag,'fig31.jpeg','-djpeg','-r600')
% 
% FigTag = figure;
% ax = axes;
% plot(time,U(:,1)' - u_f,'LineWidth',1,'LineStyle','-','color','k');
% hold on; grid on; box on;
% xlabel('t [s]','Interpreter','LaTex')
% ylabel('$\delta U$ [Nm]','Interpreter','LaTex')
% ax.FontSize = 16;
% ax.TickLabelInterpreter = 'LaTex';
% drawnow
% 
% % print(FigTag,'fig41.jpeg','-djpeg','-r600')
% 
% %___ Observed vs measured quantities _____________________________________%
% 
% FigTag = figure;
% ax = axes;
% plot(time,Xs(:,1) - x_f(2),'LineWidth',1,'color','b'); hold on; grid on; box on;
% plot(time,Xobs(:,2),'LineWidth',1,'LineStyle','--','color','b');
% xlabel('t','Interpreter','LaTex')
% ylabel('$\delta\theta$','Interpreter','LaTex')
% legend({'Measured','Observed'},'Interpreter','LaTex','Location','northeast')
% ax.FontSize = 16;
% ax.TickLabelInterpreter = 'LaTex';
% drawnow
% 
% % print(FigTag,'fig51.jpeg','-djpeg','-r600')
% 
% 
% % neighboring observed quantities + control action
% FigTag = figure;
% ax = axes;
% h = scatter(Xobs(:,2),Xobs(:,1),1,time);
% grid on; box on; 
% colormap jet;
% xlabel('$\delta\theta$','Interpreter','LaTex')
% ylabel('$\delta\dot\theta$','Interpreter','LaTex')
% ax.FontSize = 16;
% ax.TickLabelInterpreter = 'LaTex';
% hold on; 
% 
% 



