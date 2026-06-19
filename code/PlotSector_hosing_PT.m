% Data availability note:
%   The original CMIP6 and NAHosMIP model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.
%   The method used to create the processed hosing temperature data is retained at the end for reference.

%% hosing sector plots ----- Pacific temperature and PMOC responses
clc; clear; close all;
modellist = {'HadGEM3-GC31-LL'}';

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'pmoc_hos_response']);

load ([dir,'To_IP_hos_piCtl.mat']);
hos_to_ip = hos_to; pi_to_ip = pi_to; latsst_ip = latsst; levq_ip = levq;

load ([dir,'To_eq_hos_piCtlWo.mat']);
hos_to_eq = hos_to; pi_to_eq = pi_to; lonsst_eq = lonsst; latsst_eq = latsst; levq_eq = levq;

% set % --------------------------
fontsi = 10; fontname = 'Arial';
mm = 1;

%% Change pattern as a function of longitude and depth - thetao
hos_to = hos_to_eq; pi_to = pi_to_eq; lonsst = lonsst_eq; levq = levq_eq;
data = hos_to - pi_to;
data = smoothdata(data,'movmean',5);

figure(1); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[X,Y] = meshgrid(lonsst,levq);

temp = pi_to;
data(isnan(temp)) = NaN;
contourf(X,Y-10,data',[-10:0.05:10]*mm,'linestyle','none','linecolor',rgb('white'),'linewidth',0.8);
caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -12:0.5:16; c.TickLength = [0 0]; cbarrow
text(266,4200,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

clim = pi_to;
contour(X,Y+10,clim',[20 20],'linestyle','-','linecolor',rgb('orange'),'linewidth',1.5);
contour(X,Y+10,clim',[10 10],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

ax = gca;
set(ax,'FontSize',fontsi,'FontName',fontname,'LineWidth',1, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','YScale','log', ...
    'XLim',[145 360-85],'XTick',0:30:360, ...
    'YLim',[20 1500],'YTick',[10 20 50 100 200 300 500 1000 2000]);
ax.XTickLabel = {'0^o','30^oE','60^oE','90^oE','120^oE','150^oE','180^o','150^oW','120^oW','90^oW','60^oW','30^oW','0^o'};
ax.YTickLabel = {'10','20','50','100','200','300','500','1000','2000'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

%% Change pattern as a function of latitude and depth - thetao
latsst = latsst_ip; levq = levq_ip;
data = hos_to_ip - pi_to_ip;
data = smoothdata(data,'movmean',5);

figure(2); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(275); colorfinal = colorfinal(1:5:end,:);
colorfinal1 = addcolorplus(272); colorfinal1 = colorfinal1(1:5:end,:);
colorfinal = cat(1,flip(colorfinal1,1),colorfinal);
colorfinal = cat(1,colorfinal(2:12,:),colorfinal(16:end,:)); colormap(colorfinal);
[latp,pfullp] = meshgrid(latsst,levq);

contourf(latp,pfullp,data',[-1:0.05:1]*mm,'linestyle','none','linecolor',rgb('white'),'linewidth',0.5);
caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -12:0.5:16; c.TickLength = [0 0]; cbarrow
text(21,5000,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

clim = pi_to_ip;
contour(latp,pfullp,clim',[11 11],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

ax = gca;
set(ax,'FontSize',fontsi-0.5,'LineWidth',1, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','XLim',[-26 24],'XTick',(-30:10:70)-1, ...
    'YLim',[300 4000],'YTick',[300 1000 2000 3000 4000]);
ax.XTickLabel = {'30^oS','20^oS','10^oS','0^o','10^oN','20^oN','30^oN','40^oN','50^oN','60^oN','70^oN'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

% PMOC contours % --------------------------
year1 = (25:45)+5; % keep the same response window used in the original plotting script
data = nanmean(pmoc_hos(:,:,year1),3);
[X,Y] = meshgrid(latq,levmoc);
contour(X,Y,data',[1:1:10]*0.5,'linestyle','-','linecolor',rgb('black'),'linewidth',0.5);
[C1,h1] = contour(X,Y,data',[0 0],'linestyle','-','linecolor',rgb('black'),'linewidth',1.5);
clabel(C1,h1,[0 0],'color',addcolorplus(1),'fontsi',fontsi-2,'LabelSpacing',800,'FontWeight','bold');
contour(X,Y,data',[1:1:10]*-0.5,'linestyle','--','linecolor',rgb('black'),'linewidth',0.5);

%% Create processed data, for reference only
%{
%% load data
clc; clear all;
modellist = {'HadGEM3-GC31-LL'}'; model = modellist{1};
%moc 
file = ['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/msft/piControl/MOC_inSv_',model,'_piControl_run1_At_180x58.mat'];load(file);
moc_pi = MOC_IP;
file =['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/msft/u03-hos/MOC_inSv_',model,'_MOC_IP_100yr_ann_interp.mat'];load(file);
moc_hos = MOC_IP;
clear MOC_IP;clear MOC_At;clear MOC_Gl;
levmoc=levq;


levq = [0 5,10:10:190, 200:20:280, 300:100:900, 1000:100:4000];
varname = 'thetao';
for i=1; i
    model = modellist{i};
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/',varname,'/',varname,'_',model,'_timemean_1x1_30S30N.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],varname);  thetao(thetao==0)=NaN;
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev');
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    to_hos(:,:,:,:,i) = temp(1:300,:,:,:);
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/',varname,'/',varname,'_',model,'_timemean_1x1_30S30N_piControl.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],varname);  thetao(thetao==0)=NaN;
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev');
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    to_pi(:,:,:,:,i) = temp(1:300,:,:,:);
end;
    latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
    lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon'); lonsst = lonsst(1:300);

varname = 'wo';clear temp;clear wo_pi;
for i=1; i
    model = modellist{i};
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_NAHos/',varname,'/',varname,'_',model,'_timemean_1x1_30S30N_piControl.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],varname);  thetao(thetao==0)=NaN;
    lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev');
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:size(thetao,4); temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    wo_pi(:,:,:,:,i) = temp(1:300,:,:,:);
end;

%%
year = [25:45];

% % create To_eq    
im = 1;
latrange = near1(latsst,-0.5):near1(latsst,0.5);
pi_to  = squeeze(mean(mean(to_pi (:,latrange,:,:,im),2),5));
hos_to  = squeeze(mean(mean(to_hos (:,latrange,:,:,im),2),5));
hos_to = mean(hos_to(:,:,year),3);
pi_to = mean(pi_to(:,:,:),3); 
pi_wo = squeeze(mean(mean(wo_pi(:,latrange,:,[60:80]),2),4));


% % % % create To_IP-mean        
% lonrange = near1(lonsst,30):near1(lonsst,360-80); 
% hos_to = squeeze(nanmean(nanmean(to_hos(lonrange,:,:,:,1),1),5));
% pi_to = squeeze(nanmean(nanmean(to_pi(lonrange,:,:,:,1),1),5));
% hos_to = nanmean(hos_to(:,:,year),3);
% pi_to = nanmean(pi_to(:,:,:),3);
%}
