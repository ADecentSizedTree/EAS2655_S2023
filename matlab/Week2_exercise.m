%% EAS 2655
% Week 2 exercise MATLAB

% safety first
clc;clear; close all; fclose all;


%% Project 1: 

%% load Atlanta temperature data (saved as excel spread sheet in the same folder)
data_table=readtable('./ATL_MonMeanTemp_1879_2022.xlsx');

%%
% year
year=data_table.Year;
% temperature of all months
All_Month=table2array(data_table(:,2:13));
% calculate annual mean from all months
Annual=mean(All_Month,2);
% average and median of annual mean temperature
Annual_ave=mean(Annual);
Annual_median=median(Annual);

disp(['Mean of annual temperature is ',num2str(Annual_ave,4)]);
disp(['Median of annual temperature is ',num2str(Annual_median,4)]);

%% plot histogram
mu=Annual_ave;
sig=std(Annual);

figure;
bin=56:1:68;
histogram(Annual,bin);
xlabel('temperature (deg F)');
ylabel('occurrence');
set(gca,'fontsize',12);
% add normal distribution curve
hold on;

x=56:.1:68;
y=numel(Annual).*1.*normpdf(x,mu,sig);
plot(x,y,'linewidth',1.5);

%% calculate the fraction data points fall in the range of mean +- 1 s.d.

lim_1sd_l=mu-sig;
lim_1sd_u=mu+sig;

ind1=find(Annual>=lim_1sd_l & Annual<lim_1sd_u);
prob1=numel(ind1)./numel(Annual);
disp(prob1);

%% calculate the fraction data points fall in the range of mean +- 1 s.d.

lim_2sd_l=mu-2.*sig;
lim_2sd_u=mu+2.*sig;

ind2=find(Annual>=lim_2sd_l & Annual<lim_2sd_u);
prob2=numel(ind2)./numel(Annual);
disp(prob2);

%% Project 2
% Roll a dice
% Central limit theorem

% roll a dice 10 times, repeat 1,000 times
% define parameter K and prepare an empty array for M

K=1000;
M=nan(K,1);

%% use for loop. Use the random number generator. Store average values in M array
% roll the dice 10 times, record the mean, repeat 1000 times
for n=1:K
    roll = randi([1,6],10,1);
    M(n)=mean(roll);
end

%%  plot the sample mean distribution
% sample mean follows Gaussian distribution

figure;
bin=1.5:0.5:6;
histogram(M,bin);
xlabel('Average number from dice');
ylabel('number of occurrence');
set(gca,'fontsize',12);

%% calculate the statistics
%
sd=std(M);
disp(['The standard deviation of M is ', num2str(sd,3)]);

ave=mean(M);
disp(['The mean of M is ',num2str(ave,3)]);


%% Project 3
% Central limit theorem: application to Atlanta temperature

% plot time series of Annual mean temperature
figure;
hold on;
plot(year, Annual,'-','linewidth',1.5);
xlabel('Year');
ylabel('Annual mean temperature (deg F)')
title('Atlanta')
set(gca,'fontsize',12);

%% Bootstrap: repeat sampling
N=10;
K=1000;
M=nan(K,1);

for n=1:K
    data=randsample(Annual, N, false);
    M(n)=mean(data);
end
    

%% 1. Mean of sample mean equals to population mean for large enough samples

Mmean=mean(M);
disp(['Mean of sample mean is ', num2str(Mmean,5) ,'deg F']);

popmean=mean(Annual);
disp(['Population mean is ', num2str(popmean,5) ,'deg F']);


%% 2. Standard deviation of sample mean is standard error

Msd=std(M);
disp(['s.d. of sample mean is ', num2str(Msd,4) ,'deg F']);

SE=sig./sqrt(N);
disp(['Standard error sigma/sqrt(N) is ', num2str(SE,4) ,'deg F']);

%% 3. Sample mean follows a Gaussian distribution (for large enough samples)

dx=0.1;
bins=60:dx:66;
figure;
hold on;
histogram(M,bins);


mu=Mmean;
sig=SE;
% overlay gaussian curve
x=bins;
y=numel(M).*dx.*normpdf(x,mu,sig);
plot(x,y,'linewidth',1.5);

%% is the temperature in the last decade warmer than the climatological mean?

T_all=mean(Annual);
disp(['The average annual temperature from 1879 to 2022 is ', num2str(T_all,5) ,'deg F']);

T_2013_2022=mean(Annual(end-9:end));
disp(['The average annual temperature from 2013 to 2022 is ', num2str(T_2013_2022,5) ,'deg F']);

%% plot 95 percentile and 99 percentile
T95=prctile(M,95);
T99=prctile(M,99);

dx=0.1;
bins=60:dx:66;

%%
figure;
hold on;
histogram(M,bins);

mu=Mmean;
sig=SE;
% overlay gaussian curve
x=bins;
y=numel(M).*dx.*normpdf(x,mu,sig);
plot(x,y,'linewidth',1.5);

% # add a verticle line for 95 percentile
plot([T95,T95],[0.,100.],'-','linewidth',1.5);

% # add a verticle line for 99 percentile
plot([T99,T99],[0.,100.],'-','linewidth',1.5);

xlabel('Annual temperature, deg F');
ylabel('frequency');


%%
figure;
hold on;
histogram(M,bins);

mu=Mmean;
sig=SE;
% overlay gaussian curve
x=bins;
y=numel(M).*dx.*normpdf(x,mu,sig);
plot(x,y,'linewidth',1.5);

% # add a verticle line for 95 percentile
plot([T95,T95],[0.,100.],'-','linewidth',1.5);

% # add a verticle line for 99 percentile
plot([T99,T99],[0.,100.],'-','linewidth',1.5);

% # add a verticle line for last 10-year temperature
plot([T_2013_2022,T_2013_2022],[0.,100.],'-','linewidth',1.5);

xlabel('Annual temperature, deg F');
ylabel('frequency');
