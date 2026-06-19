
% Data availability note:
%   The original CMIP6 model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.
%   The method used to create the processed 1500-3000 m volume-transport data is retained at the end for reference.

%% maps ----- 1500-3000 m ocean volume transport changes
clc; clear; close all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'IVTx1500to3000_cmip6_hist_sst245.mat']); lon = lonsst; lat = latsst;
load ([dir,'IVTy1500to3000_cmip6_hist_sst245.mat']); lon = lonsst; lat = latsst;
load ([dir,'moc_at_cmip6_hist_sst245.mat']);

% set % --------------------------
fontsi = 10; fontname = 'Arial';
plot_type = 'regressed';  % 'projected' or 'regressed'

clear co; co(:,1) = [1 1 1]*0.2;  co(:,2) = [1 1 1]*0.7;  co(:,3) = addcolorplus(264);  co(:,4) = addcolorplus(266);
co(:,5) = addcolorplus(260);  co(:,6) = addcolorplus(262);  co(:,7) = addcolorplus(256);  co(:,8) = addcolorplus(258);
co(:,9) = addcolorplus(252);  co(:,10) = addcolorplus(254); co(:,11) = addcolorplus(249); co(:,12) = addcolorplus(251);
co = co';

% Calculate AMOC maximum index % --------------------------
latrange = near1(latq,0):near1(latq,65);
levrange = near1(levq,500):near1(levq,2000);
amoc_max_hist = squeeze(max(max(moc_at_hist(latrange,levrange,:),[],1),[],2));
amoc_max_fut  = squeeze(max(max(moc_at_fut (latrange,levrange,:),[],1),[],2));
amoc_max_diff = amoc_max_fut - amoc_max_hist;

%% Plot meridional transport
    mm = 0.2;
    im = [16 20 21 25 28 29];
if strcmp(plot_type,'regressed')
    clear reg_moc tt;
    for i = 1:size(fut_vo,1)
    for j = 1:size(fut_vo,2)
        x = -amoc_max_diff(:);
        y = squeeze(fut_vo(i,j,:) - hist_vo(i,j,:));
        x(im) = NaN; y(im) = NaN;
        loc = isfinite(x) & isfinite(y);
        [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)]);
        reg_moc(i,j) = b(2)*8;
        tt(i,j) = stats(3);
    end
    end
    reg_moc(reg_moc>20) = NaN; 
else
    im = [1:15,17:19,22:30];
    reg_moc = nanmean(fut_vo(:,:,im),3) - nanmean(hist_vo(:,:,im),3);
end

figure(1); set(gcf,'Color','w','Position',[0 100 350 200]);
axes('Position',[0.20 0.17 0.70 0.72]); hold on;
m_proj('Equidistant Cylindrical','lon',[-90 360-100],'lat',[-70 70]);

colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colorfinal = colorfinal(2:end-1,:); colormap(colorfinal);
[latp,pfullp] = meshgrid(cat(1,lon-360,lon),lat);
data = reg_moc';
data = cat(2,data,data);
data = smoothdata(data,'movmean',5);

[C0,h01] = m_contour(latp,pfullp,data,[0.5:1:10]*mm,'linestyle','-','linecolor',co(7,:),'linewidth',0.8);
[C0,h02] = m_contour(latp,pfullp,data,-1*[0.5:1:10]*mm,'linestyle','-','linecolor',co(9,:),'linewidth',0.8);

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

%% Plot zonal transport
    mm = 0.4;

if exist('lonsst','var') == 0; lonsst = lon; end
if exist('latsst','var') == 0; latsst = lat; end

if strcmp(plot_type,'regressed')
    clear reg_moc tt;
    for i = 1:size(fut_uo,1)
    for j = 1:size(fut_uo,2)
        x = -amoc_max_diff(:);
        y = squeeze(fut_uo(i,j,:) - hist_uo(i,j,:));
        x([im]) = NaN;
        y([im]) = NaN;
        loc = isfinite(x) & isfinite(y);
        [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)]);
        reg_moc(i,j) = b(2)*8;
        tt(i,j) = stats(3);
    end
    end
else
    im = [1:30];
    reg_moc = nanmean(fut_uo(:,:,im),3) - nanmean(hist_uo(:,:,im),3);
end

figure(2); set(gcf,'Color','w','Position',[0 100 350 200]);
axes('Position',[0.20 0.17 0.70 0.72]); hold on;
m_proj('Equidistant Cylindrical','lon',[-90 360-100],'lat',[-70 70]);

colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[latp,pfullp] = meshgrid(cat(1,lonsst-360,lonsst),latsst);
data = reg_moc';
data = cat(2,data,data);
data = smoothdata(data,'movmean',3);

[C0,h01] = m_contour(latp,pfullp,data,[0.5:1:10]*mm,'linestyle','-','linecolor',co(7,:),'linewidth',0.8);
[C0,h02] = m_contour(latp,pfullp,data,-1*[0.5:1:10]*mm,'linestyle','-','linecolor',co(9,:),'linewidth',0.8);

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

%% Create UV volume transport data, for reference only
%{
clc; clear all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';
im = [1:15,17:30];
levq = [100:100:4000]; % upper

for i=im; i
    model = modellist{i}; 
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/vo/historical_r1/vo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'vo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    vo_hist(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/vo/ssp245_r1/vo_',model,'_ssp245_run*.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'vo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    vo_fut(:,:,:,i) = temp;
end;clear thetao;clear temp;
        latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
        lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon');

lev=levq;lon=lonsst;lat=latsst;grid =1;
r = 6400000; pi = 3.14;
dlev = diff(lev,1,2); dlev(end+1)=dlev(end);
dx = 2*pi*r/360 * grid;
A = dlev.*dx;
for i=1:size(vo_fut,1), for j=1:size(vo_fut,2), for m=1:30;
vo_fut (i,j,:,m) = squeeze(vo_fut (i,j,:,m)).*A' ./10^6;
vo_hist(i,j,:,m) = squeeze(vo_hist(i,j,:,m)).*A' ./10^6;
end;end;end;

% u(cm/s) * A(m2) /100 / 10^6 = Sv --- CESM1
% u(m/s) * A(m2) / 10^6 = Sv   --- CMIP6


im = [1:15,17:30];
levq = [100:100:4000]; % upper
for i=im; i
    model = modellist{i}; 
    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/uo/historical_r1/uo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_hist(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/uo/ssp245_r1/uo_',model,'_ssp245_run*.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_fut(:,:,:,i) = temp;
end;clear thetao;clear temp;
        latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
        lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon');

lev = levq; grid = 1;
r = 6400000; pi = 3.14;
dlev = diff(lev,1,2); dlev(end+1)=dlev(end);
dx = 2*pi*r/360 * grid;
A = dlev.*dx;
for i=1:size(uo_hist,1), for j=1:size(uo_hist,2), for m=1:30;
uo_fut (i,j,:,m) = squeeze(uo_fut (i,j,:,m)).*A' ./10^6;
uo_hist(i,j,:,m) = squeeze(uo_hist(i,j,:,m)).*A' ./10^6;
end;end;end;

% u(cm/s) * A(m2) /100 / 10^6 = Sv --- CESM1
% u(m/s) * A(m2) / 10^6 = Sv   --- CMIP6


levrange = near1(lev,1500):near1(lev,3000);
hist_vo = squeeze(nansum(vo_hist(:,:,levrange,:),3));
fut_vo  = squeeze(nansum(vo_fut (:,:,levrange,:),3)); 

hist_uo = squeeze(nansum(uo_hist(:,:,levrange,:),3));
fut_uo  = squeeze(nansum(uo_fut (:,:,levrange,:),3));
%}
