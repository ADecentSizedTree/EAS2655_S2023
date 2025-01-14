% Week 6: Week6_exercise_ocean
% Multiple linear regression
% Go-SHIP line P18

clc;clear;close all;fclose all;

%% load data
data=readtable('33RO20161119_hy1.csv');
stn=data.STNNBR(1:end-1);
o2=data.OXYGEN(1:end-1);
no3=data.NITRAT(1:end-1);
dic=data.TCARBN(1:end-1);
sil=data.SILCAT(1:end-1);
p=data.CTDPRS(1:end-1);
t=data.CTDTMP(1:end-1);
sp=data.CTDSAL(1:end-1);
lat=data.LATITUDE(1:end-1);
lon=data.LONGITUDE(1:end-1);

%% data cleaning: replace missing values with NaN
stn(stn==-999)=NaN;
t(t==-999)=NaN;
p(p==-999)=NaN;
sp(sp==-999)=NaN;
o2(o2==-999)=NaN;
no3(no3==-999)=NaN;

%% quick look at a single station
station=50;
ind= (stn==station);

figure;
subplot(2,2,1);
hold on;
plot(t(ind),p(ind),'.-');
set(gca, 'YDir','reverse');
set(gca,'box','on');
ylim([0 5000]);
xlabel('temperature, deg C');
title(['temperature, site = ',num2str(station)]);
ylabel('CTD pressure, dbar');

subplot(2,2,2);
hold on;
plot(sp(ind),p(ind),'.-');
set(gca, 'YDir','reverse');
set(gca,'box','on');
ylim([0 5000]);
xlabel('Salinity, psu')
title(['Salinity, site = ',num2str(station)])
ylabel('CTD pressure, dbar');

subplot(2,2,3);
hold on;
plot(o2(ind),p(ind),'.-');
set(gca, 'YDir','reverse');
set(gca,'box','on');
ylim([0 5000]);
xlabel('O2, umol/kg')
title(['O2, site = ',num2str(station)])
ylabel('CTD pressure, dbar');

subplot(2,2,4);
hold on;
plot(no3(ind),p(ind),'.-');
set(gca, 'YDir','reverse');
set(gca,'box','on');
ylim([0 5000]);
xlabel('NO3, umol/kg')
title(['NO3, site = ',num2str(station)])
ylabel('CTD pressure, dbar');


%%
% Can we use multiple linear regression to estimate NO3 
% as a function of (T,S,P,O2)?
station=50;
ind= (stn==station);
N=numel(t(ind));
A=ones([N,5]);
A(:,1)=t(ind);
A(:,2)=sp(ind);
A(:,3)=p(ind);
A(:,4)=o2(ind);

b=no3(ind);
xvec=A\b;
disp(xvec);

%% plot the result (trained with data from the same site)
figure;
hold on;
plot(no3(ind),p(ind),'.-','DisplayName','Measured data');
plot(A*xvec,p(ind),'-','DisplayName','Predicted by MLR')

set(gca, 'YDir','reverse');
set(gca,'box','on');
legend('location','southwest');

ylim([0 5000]);
xlabel('NO3, umol/kg')
title(['NO3, site = ',num2str(station),' , training set'])
ylabel('CTD pressure, dbar');


%%
% validate using another site
% validation set 
station=60;
ind= (stn==station);
N=numel(t(ind));
A=ones([N,5]);
A(:,1)=t(ind);
A(:,2)=sp(ind);
A(:,3)=p(ind);
A(:,4)=o2(ind);
b=no3(ind);

no3_predict=A*xvec;

figure;
hold on;
plot(no3(ind),p(ind),'.-','DisplayName','Measured data');
plot(no3_predict,p(ind),'-','DisplayName','Predicted by MLR')

set(gca, 'YDir','reverse');
set(gca,'box','on');
legend('location','southwest');

ylim([0 5000]);
xlabel('NO3, umol/kg');
title(['NO3, site = ',num2str(station),' , validation set']);
ylabel('CTD pressure, dbar');




