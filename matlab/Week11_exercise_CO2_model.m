% Week 11: Exercise 1 
% CO2 box model
% 
%% safety first
clc;clear;close all;fclose all;

%% read atmospheric CO2 concentration from Mauna Loa
% opts = detectImportOptions(filename, 'FileType', 'spreadsheet')
%% import data
% readtable automatically skip non-data rows
dt=readtable('./co2_mm_mlo.csv');
time=dt.decimalDate;
co2=dt.average;
co2(co2<0)=NaN;

%% let's plot data from 1990
ind=(time>=1990)&(~isnan(co2));

figure;
hold on;
plot(time(ind),co2(ind),'-')
xlabel('time')
ylabel('MLO CO2, ppmv')

%% Part I: estimate parameters using MLR, plot the analytic solution
t0=1990;
x=time(ind)-t0;
y=co2(ind);
N=length(x);


%  assemble the matrix
A=ones(N,3); % N x 3 matrix
A(:,2)=sin(2*pi*x); % sin(2*pi*t) term
A(:,3)=x; % t-t0 term

% perform MLR using pseudo inverse
xvec=pinv(A)*y;
disp(xvec);
% estimate y using fitted paramters
yest=A*xvec;

%% compare model vs obs.
figure;
hold on;
plot(time(ind),co2(ind),'-','DisplayName','observed')
plot(time(ind),yest,'-','DisplayName','modeled, analytical')
legend()
xlabel('time');
ylabel('MLO CO2, ppmv');

%% Part II: numerical solution



% Numerical solution 
% setup model parameters
dt=0.01; % time step 0.01 year
B=2.837*2*pi; % respiration and photosynthesis cycles, ppmv/year
F=4.049; % fossil fuel emissions, ppmv/year
O=2; % ocean uptake, ppmv/year

X0=349.432; % initial CO2 concentration at t0
t0=1990; % start time
t1=2021; % end time

% generate time vector
T=t0:dt:t1;

% number of time steps
N=length(T);

X=0*T; % initialize X values with zeros

X(1)=X0; % initial value of X

%% numerical solution
% forward Euler method
for ii=2:N 
    % ii is for the time step n+1
    t=T(ii)-t0; % time of current step
    % X value in the previous time step
    Xn=X(ii-1);    
    dX_dt=fun_ODE(t,Xn, B, F, O);
    X(ii)=Xn+dX_dt*dt;
end

%%
figure;
hold on;
plot(time(ind),co2(ind),'-','DisplayName','observed')
plot(T,X,'-','DisplayName','modeled, numerical')
legend()
xlabel('time');
ylabel('MLO CO2, ppmv');

%% %%% Part III: Improve the model with actual CO2 emission

% improve the model with time-varied CO2 emissions
% https://ourworldindata.org/co2-emissions%global-co2-emissions

df_emis=readtable('CO2_Emissions.txt', 'HeaderLines', 1);
data_emis=table2array(df_emis);
Year_emis=data_emis(:,1);
% unit: billion tonnes (10^12 kg)
CO2_emis=data_emis(:,2);

%% unit conversion from gt/year to ppmv/year
m_air=5.148e18; % total mass of atmosphere, kg
CO2_emis_ppm=CO2_emis*1e12/m_air*(29/44)*1e6; % convert the unit: ppm/year

%% plot CO2 emission
figure;
hold on;
plot(Year_emis,CO2_emis_ppm,'o-','DisplayName','CO2 emission');
xlabel('time');
ylabel('CO2 emission, ppmv/year');
legend();


%%

% Numerical solution 
% setup model parameters
dt=0.01; % time step 0.01 year
B=20; % respiration and photosynthesis cycles, ppmv/year
% we will dynamically update F and O values in the loop
% F=4; % fossil fuel emissions, ppmv/year
% O=2; % ocean uptake, ppmv/year

co2_sel=co2(ind);
X0=co2_sel(1); % initial CO2 concentration at t0
t0=1990; % start time
t1=2022; % end time

% generate time vector
T=t0:dt:t1;

% number of time steps
N=length(T);

X=0*T; % initialize X values with zeros

X(1)=X0; % initial value of X

% get F and O values
F_vec=interp1(Year_emis,CO2_emis_ppm,T);
O_vec=0.475*F_vec;

%% numerical solution
% 
for ii=2:N 
    % ii is for the time step n+1
    t=T(ii)-t0; % time of current step
    % X value in the previous time step
    F=F_vec(ii);
    O=O_vec(ii);
    
    Xn=X(ii-1);    
    dX_dt=fun_ODE(t,Xn, B, F, O);
    X(ii)=Xn+dX_dt*dt;
end

%%
figure;
hold on;
plot(time(ind),co2(ind),'-','DisplayName','observed')
plot(T,X,'-','DisplayName','modeled, numerical')
legend()
xlabel('time');
ylabel('MLO CO2, ppmv');

%%
% define the function for dX/dt
function [dX_dt]=fun_ODE(t,X, B, F, O)
dX_dt=B*cos(2*pi*t)+F-O;
end

