% Data availability note:
%   The original CMIP6 model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.
%   The method used to create the processed ADV data is retained at the end for reference.

%% maps ----- AMOC-regressed surface heat-budget and ocean-advection terms
clc; clear; close all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'moc_at_cmip6_hist_sst245.mat']); levmoc = levq;
load ([dir,'Do_cmip6_hist_sst245.mat']);
load ([dir,'ADV_WcTa_cmip6_hist_sst245.mat']);
load ([dir,'tauu_cmip6_hist_sst245.mat']);
load ([dir,'tauv_cmip6_hist_sst245.mat']);

% set % --------------------------
fontsi = 10; fontname = 'Arial';
im = 1:30; alpha = 0.05; mm = 25;

% Calculate AMOC maximum index % --------------------------
latrange = near1(latq,0):near1(latq,65);
levrange = near1(levmoc,500):near1(levmoc,2000);
amoc_max_hist = squeeze(max(max(moc_at_hist(latrange,levrange,:),[],1),[],2));
amoc_max_fut  = squeeze(max(max(moc_at_fut (latrange,levrange,:),[],1),[],2));
amoc_max_diff = amoc_max_fut - amoc_max_hist;

%% Regressed Pattern - Do
clear reg_moc tt;
for i = 1:size(fut,1)
for j = 1:size(fut,2)
    x = -amoc_max_diff(:);
    y = squeeze(fut(i,j,:) - hist(i,j,:));
    loc = isfinite(x) & isfinite(y);
    [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)],alpha);
    reg_moc(i,j) = b(2)*8;
    tt(i,j) = stats(3);
end
end
data = smoothdata(reg_moc,'movmean',5);

figure(1); set(gcf,'Color','w','Position',[0 100 450 140]);
axes('Position',[0.10 0.35 0.80 0.60]); hold on;
m_proj('Equidistant Cylindrical','lon',[40 359],'lat',[-20 20]);
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[X,Y] = meshgrid(lonsst,latsst);
m_contourf(X,Y,data',[-20:0.05:20]*mm,'linestyle','none'); shading(gca,'interp'); caxis([-4 4]*mm*0.1);

[XIN,YIN] = meshgrid(1:0.5:360,-20:0.1:20);
ttIN = interp2(X,Y,tt',XIN,YIN);
[Xs,Ys] = m_ll2xy(XIN,YIN);
mask = ttIN <= 0.05;
stipple(Xs,Ys,mask,'density',120,'color',[0 0 0],'marker','.','markersize',1);

lonrange = near1(lonsst,180):near1(lonsst,360-90); latrange = near1(latsst,-5):near1(latsst,5);
kuang = zeros(size(data)); kuang(lonrange,latrange) = 100;
m_contour(X,Y,kuang',[100 100],'linestyle','-','linecolor','k','linewi',0.5);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8,'linewidth',1);
m_grid('box','on','linewidth',0.5,'tickLength',0.005,'linest','none','xtick',-360:60:360,'ytick',-80:10:90,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.45 1]);

%% Regressed Pattern - ADV
% 
fut_mld = WcTa_fut;
hist_mld = WcTa_hist;
termlabel = 'W_cT_a';


im = [1:7,9,11:15,17:19,22:30];
clear reg_moc tt;
for i = 1:size(fut_mld,1)
for j = 1:size(fut_mld,2)
    x = -amoc_max_diff(:); x = x(im);
    y = squeeze(fut_mld(i,j,im) - hist_mld(i,j,im));
    loc = isfinite(x) & isfinite(y);
    [b,~,~,~,stats] = regress(y(loc),[ones(sum(loc),1),x(loc)],alpha);
    reg_moc(i,j) = b(2)*8;
    tt(i,j) = stats(3);
end
end
data = reg_moc;
data(data>10) = 10; data(data<-10) = -10;
data = smoothdata(data,'movmean',5);

figure(2); set(gcf,'Color','w','Position',[0 100 450 140]);
axes('Position',[0.10 0.35 0.80 0.60]); hold on;
m_proj('Equidistant Cylindrical','lon',[40 359],'lat',[-20 20]);
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
[Xq,Yq] = meshgrid(lonsst,latsst);
m_contourf(Xq,Yq,data',[-10:0.05:10]*mm,'linestyle','none'); caxis([-4 4]*mm*0.1);

[XIN,YIN] = meshgrid(1:0.5:360,-20:0.1:20);
ttIN = interp2(Xq,Yq,tt',XIN,YIN);
[Xs,Ys] = m_ll2xy(XIN,YIN);
mask = ttIN <= 0.05;
stipple(Xs,Ys,mask,'density',120,'color',[0 0 0]+0.5,'marker','.','markersize',1);

lonrange = near1(lonsst,180):near1(lonsst,360-90); latrange = near1(latsst,-5):near1(latsst,5);
kuang = zeros(size(data)); kuang(lonrange,latrange) = 100;
m_contour(Xq,Yq,kuang',[100 100],'linestyle','-','linecolor','k','linewi',0.5);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8,'linewidth',1);
m_grid('box','on','linewidth',0.5,'tickLength',0.005,'linest','none','xtick',-360:60:360,'ytick',-80:10:90,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.45 1]);
text(0.03,0.85,termlabel,'Units','normalized','FontSize',fontsi+1,'FontName',fontname);

% wind stress vector % --------------------------
im = 1:30;
latrange = near1(latsst,-90):near1(latsst,90);
[Xq,Yq] = meshgrid(lonsst,latsst(latrange));
ddx = 10; ddy = 5; scale = 0.1;

datau = tau_fut(:,latrange,:) - tau_hist(:,latrange,:);
datav = tav_fut(:,latrange,:) - tav_hist(:,latrange,:);

clear reg_moc_u reg_moc_v;
for i = 1:size(datau,1)
for j = 1:size(datau,2)
    x = -amoc_max_diff(:);
    X = [ones(length(x),1),x];
    y = squeeze(datau(i,j,:)); loc = isfinite(x) & isfinite(y);
    [b,~,~,~,~] = regress(y(loc),X(loc,:),alpha); reg_moc_u(i,j) = b(2)*8;
    y = squeeze(datav(i,j,:)); loc = isfinite(x) & isfinite(y);
    [b,~,~,~,~] = regress(y(loc),X(loc,:),alpha); reg_moc_v(i,j) = b(2)*8;
end
end

datau = reg_moc_u; datav = reg_moc_v;
datau(isnan(fut_mld(:,latrange,11))) = NaN;
datav(isnan(fut_mld(:,latrange,11))) = NaN;
data = (datau.^2 + datav.^2).^(1/2);
datau(data<0.001) = NaN;
datav(data<0.001) = NaN;

datau(near1(lonsst,300):near1(lonsst,310),near1(latsst,-15):near1(latsst,-10)) = 0.02;
datav(near1(lonsst,300):near1(lonsst,310),near1(latsst,-15):near1(latsst,-10)) = 0;
m_text(303,-10,'0.02 Pa','HorizontalAlignment','center','FontSize',fontsi,'FontName',fontname);
m_vec(scale,Xq(1:ddy:end,1:ddx:end),Yq(1:ddy:end,1:ddx:end), ...
    datau(1:ddx:end,1:ddy:end)',datav(1:ddx:end,1:ddy:end)', ...
    rgb('black'),'headlength',2,'edgeclip','on','headangle',45,'centered','yes','shaftwidth',0.5);








%% create processed data, for reference only
% clc; clear all;
% modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';
% 
% varname = 'hfls';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% hfls_hist = hist; 
% hfls_fut  = fut; 
% 
% varname = 'hfss';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% hfss_hist = hist; 
% hfss_fut  = fut; 
% 
% varname = 'rlds';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% rlds_hist = hist; 
% rlds_fut  = fut; 
% 
% varname = 'rsds';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% rsds_hist = hist; 
% rsds_fut  = fut; 
% 
% varname = 'rlus';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% rlus_hist = hist; 
% rlus_fut  = fut; 
% 
% varname = 'rsus';clear hist;clear fut;
% for i=1:30; i
%     model = modellist{i};
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         hist(:,:,i) = temp;
%         filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
%         temp = ncread([filelist(1).folder,'/',filelist(1).name],varname);
%         fut(:,:,i) = temp;
% end;
% rsus_hist = hist; 
% rsus_fut  = fut; 
% 
% latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
% lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon');
% 
% hist = (hfss_hist+hfls_hist)*-1 + (rlds_hist-rlus_hist) + (rsds_hist-rsus_hist); hist = -hist;
% fut  = (hfss_fut +hfls_fut )*-1 + (rlds_fut -rlus_fut ) + (rsds_fut -rsus_fut );  fut  = -fut;
% termlabel = 'D_o';
% 


%% create processed data, for reference only
%{
clc; clear all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';
levq = [0:1:60];% only upper is cared, apply to mixed layer analysis

varname = 'mlotst',
im = [1:7,9:19,22,24:27,29,30]; 
for i=im;
    model = modellist{i};
        filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
        temp = ncread([filelist(1).folder,'/',filelist(1).name],varname); temp (temp>5000) = NaN; temp (temp==0) = NaN;
        mldhist(:,:,i) = temp;
end;
        latsst = ncread([filelist(1).folder,'/',filelist(1).name],'lat');
        lonsst = ncread([filelist(1).folder,'/',filelist(1).name],'lon');
mldhist = nanmean(mldhist(:,:,im),3);

for i=1:size(mldhist,1);for j=1:size(mldhist,2);
    levmid(i,j) = near1(levq,mldhist(i,j));
end;end;
% ---------

im = [1:30]; varname = 'tauu',
for i=im;
    model = modellist{i};
        filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
        temp = ncread([filelist(1).folder,'/',filelist(1).name],varname); temp (temp>5000) = NaN; temp (temp==0) = NaN;
        tau_hist(:,:,i) = temp;
        filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
        temp = ncread([filelist(1).folder,'/',filelist(1).name],varname); temp (temp>5000) = NaN; temp (temp==0) = NaN;
        tau_fut(:,:,i) = temp;
end;
im = [1:30]; varname = 'tauv',
for i=im;
    model = modellist{i};
        filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/historical_r1/',varname,'_',model,'_historical_run*.nc']);  
        temp = ncread([filelist(1).folder,'/',filelist(1).name],varname); temp (temp>5000) = NaN; temp (temp==0) = NaN;
        tav_hist(:,:,i) = temp;
        filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/',varname,'/ssp245_r1/',varname,'_',model,'_ssp245_run*.nc']);  
        temp = ncread([filelist(1).folder,'/',filelist(1).name],varname); temp (temp>5000) = NaN; temp (temp==0) = NaN;
        tav_fut(:,:,i) = temp;
end;


im=[1:30]; 'thetao'
for i=im; model = modellist{i}; 

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

end;clear thetao;clear temp;

im=[1:15,17:30];  'uo vo'
for i=im; model = modellist{i}; 

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/uo/historical_r1/uo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%% 不需要
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_hist(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/uo/ssp245_r1/uo_',model,'_ssp245_run*.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'uo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    uo_fut(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/vo/historical_r1/vo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'vo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%% 不需要
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


im=[1:7,9,11:15,17:19,22:30]; 'wo'
for i=im; model = modellist{i}; 

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/wo/historical_r1/wo_',model,'_historical_run*.nc']);clear temp;
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'wo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models 
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    wo_hist(:,:,:,i) = temp;

    filelist = dir(['/Users/chenxiaodan/Documents/MOC/PostProcData_CMIP6/wo/ssp245_r1/wo_',model,'_ssp245_run*.nc']);
    thetao = ncread([filelist(1).folder,'/',filelist(1).name],'wo');  
        if i == 22;  lev = ncread([filelist(1).folder,'/',filelist(1).name],'olevel');  %  IPSL
        else;        lev = ncread([filelist(1).folder,'/',filelist(1).name],'lev'); %ocean depth coordinate in m
        end;         if i == 6 | i == 7; lev = lev/100; end; % for CESM models %%%%%%%
    clear temp;for ix=1:size(thetao,1);for j=1:size(thetao,2); for im=1:1; temp(ix,j,:,im)=interp1(lev,squeeze(thetao(ix,j,:,im)),levq); end;end;end; % vertical interp
    wo_fut(:,:,:,i) = temp;

end;clear thetao;clear temp;
wo_fut (wo_fut >10)=NaN; wo_hist(wo_hist>10)=NaN;

%% calculate 3d adv 
tic
rou = 1025; %kg m-3
cp = 4000; %J (K kg)-1
r0=6400000; %m
dz = diff(levq,1,2);dz(end+1) = dz(end);
dx = 2*3.14*r0/360;
dy = dx;

% x - total
hist_tx = diff(to_hist,1,1)./dx; hist_tx(end+1,:,:,:) = hist_tx(end,:,:,:);
fut_tx  = diff(to_fut, 1,1)./dx; fut_tx (end+1,:,:,:) = fut_tx(end,:,:,:);
hist_ut = hist_tx.*uo_hist;
fut_ut  = fut_tx .*uo_fut;
hist_ut_total = -rou*cp*hist_ut.*mldhist;
fut_ut_total  = -rou*cp*fut_ut.*mldhist;
% x - due to uchange using climTx
hist_ut = hist_tx.*uo_hist;
fut_ut  = hist_tx.*uo_fut;
hist_ut_dyn = -rou*cp*hist_ut.*mldhist;
fut_ut_dyn  = -rou*cp*fut_ut.*mldhist;
% x - due to T change using climU
hist_ut = hist_tx.*uo_hist;
fut_ut  = fut_tx .*uo_hist;
hist_ut_thermo = -rou*cp*hist_ut.*mldhist;
fut_ut_thermo  = -rou*cp*fut_ut.*mldhist;
% y - total
hist_ty = diff(to_hist,1,2)./dy; hist_ty(:,end+1,:,:) = hist_ty(:,end,:,:);
fut_ty  = diff(to_fut, 1,2)./dy; fut_ty(:,end+1,:,:)  = fut_ty(:,end,:,:);
hist_vt = hist_ty.*vo_hist; %%%
fut_vt  = fut_ty .*vo_fut;%%%
hist_vt_total= -rou*cp*hist_vt.*mldhist;
fut_vt_total = -rou*cp*fut_vt.*mldhist;
% y - due to vchange using climTy
hist_vt = hist_ty.*vo_hist;%%%
fut_vt  = hist_ty.*vo_fut;%%%
hist_vt_dyn= -rou*cp*hist_vt.*mldhist;
fut_vt_dyn = -rou*cp*fut_vt.*mldhist;
% y - due to T change using climV
hist_vt = hist_ty.*vo_hist;%%%
fut_vt  = fut_ty .*vo_hist;%%%
hist_vt_thermo= -rou*cp*hist_vt.*mldhist;
fut_vt_thermo = -rou*cp*fut_vt.*mldhist;
% w - total
hist_tz = diff(to_hist,1,3); hist_tz(:,:,end+1,:) = hist_tz(:,:,end,:);
fut_tz  = diff(to_fut, 1,3); fut_tz(:,:,end+1,:) = fut_tz(:,:,end,:);
for i = 1:size(hist_ut,3);
hist_tz(:,:,i,:) = hist_tz(:,:,i,:)./dz(i);
fut_tz(:,:,i,:) = fut_tz(:,:,i,:)./dz(i);
end;
hist_wt = hist_tz.*wo_hist; %%%
fut_wt  = fut_tz .*wo_fut; %%%
hist_wt_total= rou*cp*hist_wt.*mldhist;
fut_wt_total = rou*cp*fut_wt.*mldhist;
% w - due to wchange using climTz
hist_wt = hist_tz .*wo_hist; %%%
fut_wt  = hist_tz .*wo_fut; %%%
hist_wt_dyn= rou*cp*hist_wt.*mldhist;
fut_wt_dyn = rou*cp*fut_wt.*mldhist;
% w - due to T change using climW
hist_wt = hist_tz.*wo_hist; %%%
fut_wt  = fut_tz .*wo_hist; %%%
hist_wt_thermo= rou*cp*hist_wt.*mldhist;
fut_wt_thermo = rou*cp*fut_wt.*mldhist;


%% The horizontal advection terms are averaged over the mixed-layer depth (h) derived from model output, and the vertical velocity and vertical temperature gradient are evaluated at the base of the mixed layer. 

% fut = fut_ut_dyn; hist = hist_ut_dyn;flag = 1; termlabel='U_aT_c';
% fut = fut_ut_thermo; hist = hist_ut_thermo;flag = 1; termlabel='U_cT_a';
% fut = fut_ut_total-fut_ut_dyn-fut_ut_thermo; hist = hist_ut_total-hist_ut_dyn-hist_ut_thermo;flag = 1; termlabel='U_aT_a';

% fut = fut_vt_dyn; hist = hist_vt_dyn;flag = 1; termlabel='V_aT_c';
% fut = fut_vt_thermo; hist = hist_vt_thermo;flag = 1; termlabel='V_cT_a';
% fut = fut_vt_total-fut_vt_dyn-fut_vt_thermo; hist = hist_vt_total-hist_vt_dyn-hist_vt_thermo;flag = 1; termlabel='V_aT_a';

% fut = fut_wt_dyn; hist = hist_wt_dyn;flag = 2;termlabel='W_aT_c';
% fut = fut_wt_thermo; hist = hist_wt_thermo;  flag = 2; termlabel='W_cT_a';
fut = fut_wt_total-fut_wt_dyn-fut_wt_thermo; hist = hist_wt_total-hist_wt_dyn-hist_wt_thermo;flag = 2;termlabel='W_aT_a';

% % % % regress -----------
if flag == 1;
    for i=1:size(fut,1);for j=1:size(fut,2);for m=1:size(fut,4);
    fut_mld(i,j,m) = squeeze(nanmean(fut(i,j,1:levmid(i,j),m),3));
    hist_mld(i,j,m) = squeeze(nanmean(hist(i,j,1:levmid(i,j),m),3)); 
    end;end;end;
elseif flag == 2;
    for i=1:size(fut,1);for j=1:size(fut,2);for m=1:size(fut,4);
    fut_mld(i,j,m) = squeeze(fut(i,j,levmid(i,j),m));
    hist_mld(i,j,m) = squeeze(hist(i,j,levmid(i,j),m)); 
    end;end;end;
end;

UcTa_fut  = fut_mld;
UcTa_hist = hist_mld;
%}
