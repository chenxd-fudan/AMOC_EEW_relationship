% Data availability note:
%   The original CMIP6 model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce this figure.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.

%% maps ----- tropical Pacific dSST, AMOC-regressed dSST, and delta AMOC
clc; clear; close all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';

% load data  --------------------------
dir = ' ';
load ([dir,'moc_at_cmip6_hist_sst245.mat']);
load ([dir,'sst_global_cmip6_hist_sst245.mat']);

% set  --------------------------
fontsi = 10; fontname = 'Arial';
im = 1:30;
mm = 0.8;

%% Projected pattern - tropical Pacific relative dSST
dataxx = squeeze(sstfut(:,:,im) - ssthist(:,:,im));
data = nanmean(dataxx,3);

lonrange = near1(lonsst,130):near1(lonsst,360-90); latrange = near1(latsst,-20):near1(latsst,20);
data = data - nanmean(nanmean(data(lonrange,latrange),2),1); % remove tropical Pacific mean
data = smoothdata(data,'movmean',5);
[X,Y] = meshgrid(lonsst,latsst);

figure(1); set(gcf,'Color','w','Position',[0 100 450 140]);
axes('Position',[0.10 0.35 0.80 0.60]); hold on;
m_proj('Equidistant Cylindrical','lon',[40 359],'lat',[-20 20]);
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
m_contourf(X,Y,data',[-2:0.1:1]*mm,'linestyle','none'); shading(gca,'interp'); caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.16 0.15 0.60 0.04]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -4:0.4:0.8; cbarrow
text(2.2,-0.56,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

lonrange = near1(lonsst,180):near1(lonsst,360-90); latrange = near1(latsst,-5):near1(latsst,5);
kuang = zeros(size(data)); kuang(lonrange,latrange) = 100;
m_contour(X,Y,kuang',[100 100],'linestyle','-','linecolor','k','linewi',0.5);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8,'linewidth',1);
m_grid('box','on','linewidth',0.5,'tickLength',0.005,'linest','none','xtick',-360:60:360,'ytick',-80:10:90,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.45 1]);

%% Regressed pattern - dSST onto AMOC weakening
latrange = near1(latq,0):near1(latq,65);
levrange = near1(levq,500):near1(levq,2000);
amoc_max_hist = squeeze(max(max(moc_at_hist(latrange,levrange,:),[],1),[],2));
amoc_max_fut  = squeeze(max(max(moc_at_fut (latrange,levrange,:),[],1),[],2));
amoc_max_diff = amoc_max_fut - amoc_max_hist;

clear tt reg_moc;
x = -amoc_max_diff(im);
Xreg = [ones(length(x),1), x(:)];
for i = 1:size(sstfut,1)
for j = 1:size(sstfut,2)
    y = squeeze(sstfut(i,j,im) - ssthist(i,j,im));
    loc = isfinite(x(:)) & isfinite(y(:));
    if sum(loc) > 3
        [b,~,~,~,stats] = regress(y(loc),Xreg(loc,:));
        reg_moc(i,j) = b(2)*8;
        tt(i,j) = stats(3);
    else
        reg_moc(i,j) = NaN;
        tt(i,j) = NaN;
    end
end
end

data = smoothdata(reg_moc,'movmean',5);
figure(2); set(gcf,'Color','w','Position',[0 100 450 140]);
axes('Position',[0.10 0.35 0.80 0.60]); hold on;
m_proj('Equidistant Cylindrical','lon',[40 359],'lat',[-20 20]);
colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
m_contourf(X,Y,data',-2:0.05:2,'linestyle','none'); caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.16 0.15 0.60 0.04]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -4:0.4:0.8; cbarrow
text(2.2,-0.56,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

[XIN,YIN] = meshgrid(1:0.5:360,-20:0.1:20);
tt = interp2(X,Y,tt',XIN,YIN);
[Xs,Ys] = m_ll2xy(XIN,YIN);
mask = tt <= 0.05;
stipple(Xs,Ys,mask,'density',120,'color',[0 0 0],'marker','.','markersize',1);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8,'linewidth',1);
m_grid('box','on','linewidth',0.5,'tickLength',0.005,'linest','none','xtick',-360:60:360,'ytick',-80:10:90,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.45 1]);

%% Delta AMOC pattern
mem = 1:30;
MOChist = moc_at_hist(:,:,mem);
MOCfut  = moc_at_fut (:,:,mem);
data = nanmean(MOCfut,3) - nanmean(MOChist,3);
data(data >= 0) = NaN; % retain the negative AMOC response
clim = smoothdata(nanmean(MOChist,3),'gaussian',5);

[latp,pfullp] = meshgrid(latq,levq);
figure(3); set(gcf,'Color','w','Position',[0 100 450 140]);
axes('Position',[0.15 0.35 0.666 0.60]); hold on; box on;

colorfinal = addcolorplus(275);  colorfinal  = colorfinal(1:5:end,:);
colorfinal1 = addcolorplus(272); colorfinal1 = colorfinal1(1:5:end,:);
colorfinal = cat(1,flip(colorfinal1,1),colorfinal);
colorfinal = cat(1,colorfinal(2:12,:),colorfinal(16:end,:));
colormap(colorfinal);

contourf(latp,pfullp,data',-20:0.5:20,'linestyle','none','linecolor',rgb('white'),'linewidth',0.1);
caxis([-10 10]);
c = colorbar('horizontal','position',[0.15 0.15 0.60 0.04]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -30:5:30; cbarrow
text(61,5500,'Sv','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

[C1,h1] = contour(latp,pfullp,clim',3:3:30,'linestyle','-','linecolor',rgb('dark grey'),'linewidth',0.5);
clabel(C1,h1,6:6:18,'color',rgb('dark grey'),'LabelSpacing',400);

ax = gca;
set(ax,'FontSize',fontsi-0.6,'FontName',fontname,'LineWidth',0.8, ...
    'TickDir','out','TickLength',[0.008 0.008],'YDir','reverse', ...
    'XLim',[-30 70],'XTick',-30:10:70, ...
    'YLim',[10 4000],'YTick',[10 1000 2000 3000 4000 5000]);
ax.XTickLabel = {'30^oS','20^oS','10^oS','0^o','10^oN','20^oN','30^oN','40^oN','50^oN','60^oN','70^oN'};
ax.YTickLabel = {'10','1000','2000','3000','4000','5000'};
ylabel('Depth (m)','FontSize',fontsi,'FontName',fontname);
