%% Week 4 exercise
% regression and correlation

%% safety first
close all; fclose all; clear; clc;

%% Part 1. regression using noisy data

% number of data points
N=100;
% generate x values from 1 to N
x=[1:100]';
% y=0.5*x + noise
err=50;
y=0.5.*x+err.*(rand(N,1)-0.5);

% set-up matrix A to estimate linear fit
% Ax=b
% first column of A: x
% second column of A: 1
A=[x,ones(N,1)];
b=y; % get a column vector of y

% # estimate coefficient using pseudo inverse
xvec=A\b;
% % alternatively
% xvec2=pinv(A)*b;
disp('Part 1. fit noisy data');
disp('Estimated based on matrix pseudo inversion:');
disp(['The best fit line is y = ',num2str(xvec(1),3),...
    'x + ',num2str(xvec(2),3)]);

%% make a plot

figure;
hold on;
plot(x,y,'linewidth',1.5,'DisplayName','data');
plot(x,A*xvec,'-','linewidth',1.5,'DisplayName','fitted line')
xlabel('x');
ylabel('y');
legend('location','northwest');
print('-dpng', 'week4_fig1_noisy_data_fit.png');


%% estimating regression coefficient using covariance matrix
% y = ax + b
% we use the same x and y generated from the previous section
% assemble a matrix
D=[x,y]; % first column x, second column y
% calculate the covariance matrix
c=cov(D);
% calculate the regression coefficient a (slope)
a=c(1,2)/c(1,1);
% estimated the intercept
b=mean(y)-a*mean(x);

disp(' ');
disp('Estimated based on covariance matrix:');
disp(['The best fit line is y = ',num2str(a,3),...
    'x + ',num2str(b,3)]);
%% estimating correlation coefficient

% coefficient of determination
% R^2 value measures the fraction of variance explained by the regression
R2=c(1,2).^2./(c(1,1).*c(2,2));
disp(['R^2 = ',num2str(R2,4)]);
disp([num2str(R2*100,4),'% of the variance is explained by the linear trend.']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 2. Atlanta temperature
% import data (with missing values)
data_table=readtable('./ATL_MonMeanTemp_1879_2022_with_missing.xlsx');
% year
year=data_table.Year;
% temperature of all months
All_Month=table2array(data_table(:,2:13));
% calculate annual mean from all months
Annual=mean(All_Month,2);

%% calculate the regression coefficients
% all data
ind=~isnan(Annual);
% assemble the matrix [x,y]
D=[year(ind),Annual(ind)];
% calculate the Covariance matrix
c=cov(D);
% estimate regression coefficients
a=c(1,2)./c(1,1); % slope
b=mean(Annual(ind))-a*mean(year(ind)); % intercept

r2=(c(1,2).^2)./(c(1,1).*c(2,2)); % coefficient of determination

disp(' ');
disp('Part 2: Atlanta temperature ');
disp('Estimated based on covariance matrix:');
disp(['The temperature changes ',num2str(a,3),' deg F per year.']);
disp(['R^2 = ',num2str(r2,3)]);
disp([num2str(r2*100,4),'% of the variance is explained by the linear trend.']);

%% validate using pseudo inverse of matrix
N=numel(Annual(ind));
A=[year(ind),ones(N,1)];
xvec=pinv(A)*Annual(ind);

disp(' ');
disp('Estimated based on pseudo inverse:');
disp(['The temperature changes ',num2str(xvec(1),3),' deg F per year.']);


%% make a plot
figure;
hold on;
plot(year,Annual,'-','linewidth',1.5);
plot(year(ind),A*xvec,'-','linewidth',1.5);
xlabel('Year');
ylabel('Temperature (^\circF)');
set(gca,'fontsize',18);
print('-dpng', 'week4_fig2_atlanta_temp_fit.png');


%% calculate the regression coefficients for a selected period
% all data
ind=(~isnan(Annual)) & (year>=1970);
% assemble the matrix [x,y]
D=[year(ind),Annual(ind)];
% calculate the Covariance matrix
c=cov(D);
% estimate regression coefficients
a=c(1,2)./c(1,1); % slope
b=mean(Annual(ind))-a*mean(year(ind)); % intercept

r2=(c(1,2).^2)./(c(1,1).*c(2,2)); % coefficient of determination

disp(' ');
disp('Regression for a selected period (after 1970)');
disp('Estimated based on covariance matrix:');
disp(['The temperature changes ',num2str(a,3),' deg F per year.']);
disp(['R^2 = ',num2str(r2,3)]);
disp([num2str(r2*100,4),'% of the variance is explained by the linear trend.']);

%% make a plot
figure;
hold on;
plot(year,Annual,'-','linewidth',1.5);
plot(year(ind),a.*year(ind)+b,'-','linewidth',1.5);
xlabel('Year');
ylabel('Temperature (^\circF)');
title('Atlanta, Annual temperature');
set(gca,'fontsize',18);
print('-dpng', 'week4_fig2_atlanta_temp_fit_1970_2022.png');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part 3. Comparison of different cities
% import data (with missing values)

% Atlanta, GA
data_table1=readtable('./temperature_four_cities.xlsx','Sheet','ATL');
% Boston, MA
data_table2=readtable('./temperature_four_cities.xlsx','Sheet','BOS');
% San Francisco, CA
data_table3=readtable('./temperature_four_cities.xlsx','Sheet','SFO');
% Seattle, WA
data_table4=readtable('./temperature_four_cities.xlsx','Sheet','SEA');

% Year
year=data_table1.Year;
% Get Feb temperature for four cities
T_feb1=data_table1.Feb;
T_feb2=data_table2.Feb;
T_feb3=data_table3.Feb;
T_feb4=data_table4.Feb;

%% make a time series plot

figure;
hold on;
plot(year,T_feb1,'-','linewidth',1.5,'DisplayName','ATL');
plot(year,T_feb2,'-','linewidth',1.5,'DisplayName','BOS');
plot(year,T_feb3,'-','linewidth',1.5,'DisplayName','SFO');
plot(year,T_feb4,'-','linewidth',1.5,'DisplayName','SEA');

xlabel('Year');
ylabel('Temperature (^\circF)');
title('February Temperature');
xlim([1890,2030]);
set(gca,'fontsize',18);

legend('orientation','Horizontal','location','south');

print('-dpng', 'week4_fig3_four_cities_feb_temp.png');


%% calculation of covariance and correlation

ind=~isnan(T_feb1) & ~isnan(T_feb2) & ~isnan(T_feb3) & ~isnan(T_feb4);
D=[T_feb1(ind),T_feb2(ind),T_feb3(ind),T_feb4(ind)];
% correlation matrix
r_mat=corrcoef(D); 
% covariance matrix
c_mat=cov(D);


%% correlation plot
% atlanta vs. boston
figure;
hold on;
plot(T_feb1,T_feb2,'o','linewidth',1.5,'MarkerSize',8);
xlabel('ATL temperature (deg F)');
ylabel('BOS temperature (deg F)');
title('February');
set(gca,'fontsize',18);
print('-dpng', 'week4_fig4_feb_temp_atl_bos.png');

%%
% san francisco vs. seattle
figure;
hold on;
plot(T_feb3,T_feb4,'+','linewidth',1.5,'MarkerSize',8);
xlabel('SFO temperature (deg F)');
ylabel('SEA temperature (deg F)');
title('February');
set(gca,'fontsize',18);
print('-dpng', 'week4_fig4_feb_temp_sfo_sea.png');

%%
% atlanta vs. san francisco
figure;
hold on;
plot(T_feb1,T_feb3,'^','linewidth',1.5,'MarkerSize',8);
xlabel('ATL temperature (deg F)');
ylabel('SFO temperature (deg F)');
title('February');
set(gca,'fontsize',18);
print('-dpng', 'week4_fig4_feb_temp_atl_sfo.png');

%% test the significance
N=numel(T_feb1(ind));
t_value=r_mat.*sqrt((N-2)./(1-r_mat.^2));
% critical t value
tcrit=norminv(0.975);








