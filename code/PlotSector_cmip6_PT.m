
% Data availability note:
%   The original CMIP6 model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.
%   The method used to create the processed temperature and vertical-velocity data is retained at the end for reference.

%% sector plots ----- Pacific temperature changes and AMOC-regressed responses
clc; clear; close all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'moc_at_cmip6_hist_sst245.mat']);
load ([dir,'moc_ip_cmip6_hist_sst245.mat']);
load ([dir,'To_IP_cmip6_hist_sst245.mat']); levq200 = levq; hist_to_ip = hist_to; fut_to_ip = fut_to;
load ([dir,'To_eq_cmip6_hist_sst245_histWo.mat']);

% set % --------------------------
fontsi = 10; fontname = 'Arial';
im = 1:30;

% Calculate AMOC maximum index % --------------------------
latrange = near1(latq,0):near1(latq,65);
levrange = near1(levq,500):near1(levq,2000);
amoc_max_hist = squeeze(max(max(moc_at_hist(latrange,levrange,:),[],1),[],2));
amoc_max_fut  = squeeze(max(max(moc_at_fut (latrange,levrange,:),[],1),[],2));
amoc_max_diff = amoc_max_fut - amoc_max_hist;

%% Change pattern as a function of longitude and depth - thetao
data = nanmean(fut_to(:,:,im),3) - nanmean(hist_to(:,:,im),3); mm = 1;
clear tt;
for i = 1:size(fut_to,1)
for j = 1:size(fut_to,2)
    temp = squeeze((fut_to(i,j,im)-hist_to(i,j,im)).*data(i,j));
    tt(i,j) = length(find(temp > 0));
end
end

figure(1); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[X,Y] = meshgrid(lonsst,levq);
temp = hist_to(:,:,30); data(isnan(temp)) = NaN;

contourf(X,Y,data',[-10:0.05:10]*mm,'linestyle','none','linecolor',rgb('white'),'linewidth',0.5);
caxis([-1 1]*2.5*mm);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = (-12:1:16)*mm; c.TickLength = [0 0]; cbarrow
text(266,4200,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

clim = nanmean(hist_to(:,:,im),3); clim(isnan(temp)) = NaN;
contour(X,Y,clim',[20 20],'linestyle','-','linecolor',rgb('orange'),'linewidth',1.5);
contour(X,Y,clim',[10 10],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

imwo = [1:7,9,11:15,17:19,22:30];
data_wo = nanmean(hist_wo(:,:,imwo),3);
data_wo = smoothdata(data_wo,'gaussian',10); data_wo(isnan(temp)) = NaN;
[C1,h1] = contour(X,Y,data_wo',[20:100:1000],'linestyle','-','linecolor',addcolorplus(103),'linewidth',0.8);
clabel(C1,h1,[20:200:1000],'color',addcolorplus(103),'fontsi',fontsi-2,'LabelSpacing',600);

ax = gca;
set(ax,'FontSize',fontsi,'FontName',fontname,'LineWidth',1, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','YScale','log','XLim',[145 360-85], ...
    'XTick',0:30:360,'YLim',[20 1500],'YTick',[10 20 50 100 200 300 500 1000 2000]);
ax.XTickLabel = {'0^o','30^oE','60^oE','90^oE','120^oE','150^oE','180^o','150^oW','120^oW','90^oW','60^oW','30^oW','0^o'};
ax.YTickLabel = {'10','20','50','100','200','300','500','1000','2000'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

%% Regressed pattern as a function of longitude and depth - thetao
im = 1:30;
clear reg_moc tt;
for i = 1:size(fut_to,1)
for j = 1:size(fut_to,2)
    x = -amoc_max_diff(:);
    y = squeeze(fut_to(i,j,:) - hist_to(i,j,:));
    x = x(im); y = y(im);
    loc = isfinite(x) & isfinite(y);
    [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)]);
    reg_moc(i,j) = b(2)*8;
    tt(i,j) = stats(3);
end
end

figure(2); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[X,Y] = meshgrid(lonsst,levq);
data = smoothdata(reg_moc','gaussian',5);
temp = hist_to(:,:,30); data(isnan(temp')) = NaN;

contourf(X,Y,data,[-10:0.005:10]*10,'linestyle','none','linecolor',rgb('white'),'linewidth',0.5);
caxis([-1 1]);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -12:0.5:16; c.TickLength = [0 0]; cbarrow
text(266,4200,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

tt(near1(lonsst,360-120):end,near1(levq,100):near1(levq,600)) = 0;
tt(isnan(temp)) = NaN;
[XIN,YIN] = meshgrid(1:1:360,[0:2:28,30:5:80,80:20:250,250:100:2000]);
ttIN = interp2(X,Y,tt',XIN,YIN);
mask = ttIN <= 0.05;
stipple(XIN,YIN,mask,'density',180,'color',[0 0 0],'marker','.','markersize',1);

clim = nanmean(hist_to(:,:,im),3); clim(isnan(temp)) = NaN;
contour(X,Y,clim',[20 20],'linestyle','-','linecolor',rgb('orange'),'linewidth',1.5);
contour(X,Y,clim',[10 10],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

data_wo = nanmean(hist_wo(:,:,imwo),3);
data_wo = smoothdata(data_wo,'gaussian',10); data_wo(isnan(temp)) = NaN;
[C1,h1] = contour(X,Y,data_wo',[20:100:1000],'linestyle','-','linecolor',addcolorplus(103),'linewidth',0.8);
clabel(C1,h1,[20:200:1000],'color',addcolorplus(103),'fontsi',fontsi-2,'LabelSpacing',600);

ax = gca;
set(ax,'FontSize',fontsi,'FontName',fontname,'LineWidth',1, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','YScale','log','XLim',[145 360-85], ...
    'XTick',0:30:360,'YLim',[20 1500],'YTick',[10 20 50 100 200 300 500 1000 2000]);
ax.XTickLabel = {'0^o','30^oE','60^oE','90^oE','120^oE','150^oE','180^o','150^oW','120^oW','90^oW','60^oW','30^oW','0^o'};
ax.YTickLabel = {'10','20','50','100','200','300','500','1000','2000'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

%% Change pattern as a function of latitude and depth - thetao
im = 1:30;
data = nanmean(fut_to_ip,3) - nanmean(hist_to_ip,3);
data = smoothdata(data,'movmean',1); mm = 2.5;

figure(3); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(275); colorfinal = colorfinal(1:5:end,:);
colorfinal1 = addcolorplus(272); colorfinal1 = colorfinal1(1:5:end,:);
colorfinal = cat(1,flip(colorfinal1,1),colorfinal);
colorfinal = cat(1,colorfinal(2:12,:),colorfinal(16:end,:)); colormap(colorfinal);
[latp,pfullp] = meshgrid(latsst,levq200);

contourf(latp,pfullp,data',[-0.5:0.1:0.5]*mm,'linestyle','none','linecolor',rgb('white'),'linewidth',0.5);
caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -12:1:16; c.TickLength = [0 0]; cbarrow
text(21,5000,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

clim = nanmean(hist_to_ip,3);
temp = hist_to_ip(:,:,30); clim(isnan(temp)) = NaN;
contour(latp,pfullp,clim',[20 20],'linestyle','-','linecolor',rgb('orange'),'linewidth',1.5);
contour(latp,pfullp,clim',[10 10],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

data_moc = nanmean(moc_ip_hist(:,:,im),3);
[X,Y] = meshgrid(latq,levmoc-30);
contour(X,Y,data_moc',[1:1:100]*0.5,'linestyle','-','linecolor',addcolorplus(1),'linewidth',0.5);
[C1,h1] = contour(X,Y,data_moc',[0 0],'linestyle','-','linecolor',addcolorplus(1),'linewidth',1.5);
clabel(C1,h1,[0 0],'color',addcolorplus(1),'fontsi',fontsi-2,'LabelSpacing',800,'FontWeight','bold');
contour(X,Y,data_moc',[1:1:100]*-0.5,'linestyle','--','linecolor',addcolorplus(1),'linewidth',0.5);

clear tt;
for i = 1:size(moc_ip_hist,1)
for j = 1:size(moc_ip_hist,2)
    tt(i,j) = length(find(moc_ip_hist(i,j,im).*data_moc(i,j) >= 0));
end
end
[latpIN,pfullpIN] = meshgrid(-30:0.5:30,10:40:4000);
ttIN = interp2(X,Y,tt',latpIN,pfullpIN);
mask = ttIN >= length(im)-1;
stipple(latpIN,pfullpIN,mask,'density',60,'color',addcolorplus(103),'marker','.','markersize',1);

ax = gca;
set(ax,'FontSize',fontsi-0.5,'LineWidth',1,'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','XLim',[-26 24],'XTick',(-30:10:70)-1, ...
    'YLim',[300 4000],'YTick',[300 1000 2000 3000 4000]);
ax.XTickLabel = {'30^oS','20^oS','10^oS','0^o','10^oN','20^oN','30^oN','40^oN','50^oN','60^oN','70^oN'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

%% Regressed pattern as a function of latitude and depth - thetao
im = 1:30;
clear reg_moc tt;
for i = 1:size(fut_to_ip,1)
for j = 1:size(fut_to_ip,2)
    x = -amoc_max_diff(:);
    y = squeeze(fut_to_ip(i,j,:) - hist_to_ip(i,j,:));
    x = x(im); y = y(im);
    loc = isfinite(x) & isfinite(y);
    [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)]);
    reg_moc(i,j) = b(2)*8;
    tt(i,j) = stats(3);
end
end
data = smoothdata(reg_moc,'movmean',5); mm = 1;

figure(4); set(gcf,'Color','w','Position',[0 100 360 200]);
axes('Position',[0.20 0.26 0.60 0.70]); hold on; box on;
colorfinal = addcolorplus(275); colorfinal = colorfinal(1:5:end,:);
colorfinal1 = addcolorplus(272); colorfinal1 = colorfinal1(1:5:end,:);
colorfinal = cat(1,flip(colorfinal1,1),colorfinal);
colorfinal = cat(1,colorfinal(2:12,:),colorfinal(16:end,:)); colormap(colorfinal);
[latp,pfullp] = meshgrid(latsst,levq200);

contourf(latp,pfullp,data',[-0.5:0.1:0.5]*mm,'linestyle','none','linecolor',rgb('white'),'linewidth',0.5);
caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.20 0.10 0.55 0.036]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -12:0.5:16; c.TickLength = [0 0]; cbarrow
text(21,5000,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

[latpIN,pfullpIN] = meshgrid(-30:0.5:30,10:40:4000);
tt(near1(latsst,-5):near1(latsst,2),near1(levq200,0):near1(levq200,50)) = 0;
ttIN = interp2(latp,pfullp,tt',latpIN,pfullpIN);
mask = ttIN < 0.05;
stipple(latpIN,pfullpIN,mask,'density',60,'color',[0 0 0],'marker','.','markersize',1);

clim = nanmean(hist_to_ip,3);
temp = hist_to_ip(:,:,30); clim(isnan(temp)) = NaN;
contour(latp,pfullp,clim',[20 20],'linestyle','-','linecolor',rgb('orange'),'linewidth',1.5);
contour(latp,pfullp,clim',[10 10],'linestyle','-','linecolor',rgb('yellow'),'linewidth',1.5);

clear reg_moc tt;
for i = 1:size(moc_ip_fut,1)
for j = 1:size(moc_ip_fut,2)
    x = -amoc_max_diff(:);
    y = squeeze(moc_ip_fut(i,j,:) - moc_ip_hist(i,j,:));
    x = x(im); y = y(im);
    loc = isfinite(x) & isfinite(y);
    [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)]);
    reg_moc(i,j) = b(2)*8;
    tt(i,j) = stats(3);
end
end

[X,Y] = meshgrid(latq,levmoc);
contour(X,Y,reg_moc',[1:1:10]*0.5,'linestyle','-','linecolor',rgb('black'),'linewidth',0.5);
[C1,h1] = contour(X,Y,reg_moc'+0.01,[0 0],'linestyle','-','linecolor',rgb('black'),'linewidth',1.5);
clabel(C1,h1,[0 0],'color',addcolorplus(1),'fontsi',fontsi-2,'LabelSpacing',200,'FontWeight','bold');
contour(X,Y,reg_moc',[1:1:10]*-0.5,'linestyle','--','linecolor',rgb('black'),'linewidth',0.5);

ax = gca;
set(ax,'FontSize',fontsi-0.5,'LineWidth',1,'TickDir','out','TickLength',[0.012 0.012], ...
    'YDir','reverse','XLim',[-26 24],'XTick',(-30:10:70)-1, ...
    'YLim',[300 4000],'YTick',[300 1000 2000 3000 4000]);
ax.XTickLabel = {'30^oS','20^oS','10^oS','0^o','10^oN','20^oN','30^oN','40^oN','50^oN','60^oN','70^oN'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);

%% Create processed data, for reference only
%{
clc; clear all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';
levq = [0 5,10:10:190, 200:20:280, 300:100:900,1000:100:2000]; % upper
im=[1:30];'thetao'
for i=im; i
    model = modellist{i}; 

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/thetao/historical_r1/thetao_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'thetao');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         %if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%% 不需要
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    to_hist(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/thetao/ssp245_r1/thetao_',model,'_ssp245_run*.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'thetao');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    to_fut(:,:,:,i) = temp;

end;
clear thetao;clear temp;

im=[1:7,9,11:15,17:19,22:30]; 'wo'
for i=im;i
    model = modellist{i}; 

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/wo/historical_r1/wo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'wo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%% 不需要
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    wo_hist(:,:,:,i) = temp;

end;clear thetao;clear temp;
wo_hist(wo_hist>10)=NaN;wo_hist=wo_hist*60*60*24*365;  % m/s to m/year

        latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
        lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon');

% create To_eq        
latrange = near1(latsst,-2):near1(latsst,2);
hist_to = squeeze(mean(mean(to_hist(:,latrange,:,:),2),2));
fut_to  = squeeze(mean(mean(to_fut (:,latrange,:,:),2),2));
hist_wo = squeeze(mean(mean(wo_hist(:,latrange,:,:),2),2));

% create To_IP-mean        
lonrange = near1(lonsst,30):near1(lonsst,360-90);flag =1; mm=3;
hist_to = squeeze(nanmean(nanmean(to_hist(lonrange,:,:,:),1),1));
fut_to  = squeeze(nanmean(nanmean(to_fut (lonrange,:,:,:),1),1));
%}
