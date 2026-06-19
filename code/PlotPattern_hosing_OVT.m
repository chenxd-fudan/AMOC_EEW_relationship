% Data availability note:
%   The original NAHosMIP model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6/NAHosMIP data are publicly available from the official CMIP6/ESGF data portals.
%   The method used to create the processed 1500-3500 m hosing volume-transport data is retained at the end for reference.

%% maps ----- 1500-3500 m ocean volume transport response in the hosing experiment
clc; clear; close all;
modellist = {'HadGEM3-GC31-LL'}';

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'IVT1500to3000_hosing.mat']); lon = lonsst; lat = latsst;


% set % --------------------------
fontsi = 10; fontname = 'Arial';
clear co; co(:,1) = [1 1 1]*0.2;  co(:,2) = [1 1 1]*0.7;  co(:,3) = addcolorplus(264);  co(:,4) = addcolorplus(266);
co(:,5) = addcolorplus(260);  co(:,6) = addcolorplus(262);  co(:,7) = addcolorplus(256);  co(:,8) = addcolorplus(258);
co(:,9) = addcolorplus(252);  co(:,10) = addcolorplus(254); co(:,11) = addcolorplus(249); co(:,12) = addcolorplus(251);


%% Plot V transport
data = nanmean(data_v,3)'; mm = 0.2;
data = cat(2,data,data);
data = smoothdata(data,'movmean',5);

figure(1); set(gcf,'Color','w','Position',[0 100 350 200]);
axes('Position',[0.20 0.17 0.70 0.72]); hold on;
m_proj('Equidistant Cylindrical','lon',[-90 360-100],'lat',[-70 70]);

[latp,pfullp] = meshgrid(cat(1,lon-360,lon),lat);
[C0,h01] = m_contour(latp,pfullp,data,[0.5:1:10]*mm,'linestyle','-','linecolor',co(:,7),'linewidth',0.8);
[C0,h02] = m_contour(latp,pfullp,data,-1*[0.5:1:10]*mm,'linestyle','-','linecolor',co(:,9),'linewidth',0.8);

lonx = cat(1,lon-360,lon);
kuang = data; kuang(:) = 0;

lonrange = near1(lonx,40):near1(lonx,75);        latrange = near1(lat,-25):near1(lat,-25);  % Indian
kuang(latrange,lonrange) = 100;
m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('black'),'linewidth',2);

lonrange = near1(lonx,170):near1(lonx,180+30);   latrange = near1(lat,-25):near1(lat,-25);  % Pacific
kuang(latrange,lonrange) = 100;
m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('black'),'linewidth',2);

lonrange = near1(lonx,-50):near1(lonx,-20);      latrange = near1(lat,-25):near1(lat,-25);  % Atlantic
kuang(latrange,lonrange) = 100;
[C1,h11] = m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('white'),'linewidth',2);
m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('black'),'linewidth',2);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8);
m_coast('linewidth',1,'color',[0 0 0]+0.8);
m_grid('box','on','linewidth',0.8,'linest','none','xtick',-90:60:360,'ytick',-70:20:70,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.6 1]);
legend([h02 h01 h11],'Southward (from -0.1)','Northward (from 0.1)','Contour Interval = 0.2','fontsize',fontsi-1,'edgecolor','none');

%% Plot U transport
data = nanmean(data_u,3)'; mm = 0.4;
data = cat(2,data,data);
data = smoothdata(data,'movmean',5);

figure(2); set(gcf,'Color','w','Position',[0 100 350 200]);
axes('Position',[0.20 0.17 0.70 0.72]); hold on;
m_proj('Equidistant Cylindrical','lon',[-90 360-100],'lat',[-70 70]);

[latp,pfullp] = meshgrid(cat(1,lonsst-360,lonsst),latsst);
[C0,h01] = m_contour(latp,pfullp,data,[0.5:1:10]*mm,'linestyle','-','linecolor',co(:,7),'linewidth',0.8);
[C0,h02] = m_contour(latp,pfullp,data,-1*[0.5:1:10]*mm,'linestyle','-','linecolor',co(:,9),'linewidth',0.8);

lonx = cat(1,lonsst-360,lonsst);
kuang = data; kuang(:) = 0;

lonrange = near1(lonx,15):near1(lonx,15);
latrange = near1(latsst,-50):near1(latsst,-30);
kuang(latrange,lonrange) = 100;
[C1,h11] = m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('white'),'linewidth',2);
m_contour(latp,pfullp,kuang,[100 100],'linestyle','-','linecolor',rgb('black'),'linewidth',2);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8);
m_coast('linewidth',1,'color',[0 0 0]+0.8);
m_grid('box','on','linewidth',0.8,'linest','none','xtick',-90:60:360,'ytick',-70:20:70,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.6 1]);
legend([h02 h01 h11],'Westward (from -0.2)','Eastward (from 0.2)','Contour Interval = 0.4','fontsize',fontsi-1,'edgecolor','none');





%% Create hosing volume-transport data in HadGCM3-LL, for reference only
%{
clc; clear all;
modellist = {'HadGEM3-GC31-LL'}; im =1;
levq = [1400:20:3500]; % upper

for i=im; model = modellist{i}; 
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/vo/vo_',model,'_timemean_1x1_70S70N_piControl.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'vo');  
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    vo_pi(:,:,:,:,i) = temp(1:360,:,:,:);
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/uo/uo_',model,'_timemean_1x1_70S70N_piControl.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_pi(:,:,:,:,i) = temp(1:360,:,:,:);
end;clear thetao;clear temp;  

for i=1;  model = modellist{i};
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/vo/vo_',model,'_timemean_1x1_70S70N.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'vo');  thetao(thetao==0)=NaN;
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev');
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    vo_hos(:,:,:,:,i) = temp(1:360,:,:,:);
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/uo/uo_',model,'_timemean_1x1_70S70N.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  thetao(thetao==0)=NaN;
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev');
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_hos(:,:,:,:,i) = temp(1:360,:,:,:);
end;clear thetao;clear temp;  

        latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
        lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon'); 


lev=levq;lon=lonsst;lat=latsst;grid =1;
r = 6400000; pi = 3.14;
dlev = diff(lev,1,2); dlev(end+1)=dlev(end);
dx = 2*pi*r/360 * grid;
A = dlev.*dx;

for i=1:size(uo_hos,1), for j=1:size(uo_hos,2), for m=1:1;
uo_hos (i,j,:,m) = squeeze(uo_hos (i,j,:,m)).*A' ./10^6;
uo_pi(i,j,:,m) = squeeze(uo_pi(i,j,:,m)).*A' ./10^6;
end;end;end;

for i=1:size(uo_hos,1), for j=1:size(uo_hos,2), for m=1:1;
vo_hos (i,j,:,m) = squeeze(vo_hos (i,j,:,m)).*A' ./10^6;
vo_pi(i,j,:,m) = squeeze(vo_pi(i,j,:,m)).*A' ./10^6;
end;end;end;

% u(cm/s) * A(m2) /100 / 10^6 = Sv --- CESM1
% u(m/s) * A(m2) / 10^6 = Sv   --- CMIP6


levrange = near1(levq,1500):near1(levq,3000);
year = [26:45]; %%%%!!!!!!

% v  % ---------------- ---------------- ---------------- ----------------
fut   = squeeze(nansum(vo_hos(:,:,levrange,:),3));
hist  = squeeze(nansum(vo_pi (:,:,levrange,:),3)); 
data = fut(:,:,year) - nanmean(hist(:,:,[1:100]),3); 
data_v = data;

% u  % ---------------- ---------------- ---------------- ----------------
fut   = squeeze(nansum(uo_hos(:,:,levrange,:),3));
hist  = squeeze(nansum(uo_pi (:,:,levrange,:),3)); 
data_u  = fut(:,:,year) - nanmean(hist(:,:,year),3);
%}
