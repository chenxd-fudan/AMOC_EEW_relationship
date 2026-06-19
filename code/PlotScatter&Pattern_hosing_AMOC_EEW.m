
% Data availability note:
%   The original CMIP6 and NAHosMIP model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce these figures.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.

%% hosing ----- EEW index vs delta AMOC and tropical SST response
clc; clear; close all;
modellist = {'CanESM5','CESM2','EC-Earth3','HadGEM3-GC31-LL','HadGEM3-GC31-MM','IPSL-CM6A-LR','MPI-ESM1-2-HR','MPI-ESM1-2-LR'}';
im = 1:8;

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'eew_hos_piCtl.mat']);
load ([dir,'amoc_hos_piCtl.mat']);
load ([dir,'sst_hosing_response_TropicalMeanRomoved.mat']);

% set % --------------------------
clear co; co(:,1) = [1 1 1]*0.2;  co(:,2) = [1 1 1]*0.7;  co(:,3) = addcolorplus(264);  co(:,4) = addcolorplus(266);
co(:,5) = addcolorplus(260);  co(:,6) = addcolorplus(262);  co(:,7) = addcolorplus(256);  co(:,8) = addcolorplus(258);
fontsi = 10; fontname = 'Arial';
alpha = 0.05;   % confidence level used for the regression band

%% scatter ----- EEW index vs delta AMOC
year = 26:45;
x = nanmean(amoc_max_hos(year,im),1) - nanmean(amoc_max_pi(:,im),1);
y = nanmean(eew_hos(year,im),1)      - nanmean(eew_pi(:,im),1);

loc = isfinite(x) & isfinite(y);
x = x(loc); y = y(loc); modellist = modellist(loc); co = co(:,loc);

X = [ones(size(x(:))), x(:)];
[b,~,r,~,stats] = regress(y(:),X,alpha);
x_fine = linspace(min(x)-5,max(x)+5,100)';
X_fine = [ones(size(x_fine)), x_fine];
y_fine = X_fine * b;

n = length(y); p = length(b); df = n - p;
sigma2_hat = sum(r.^2) / df;
se_fine = sqrt(sigma2_hat * sum((X_fine / (X' * X)) .* X_fine, 2));
t_crit = tinv(1 - alpha/2, df);
ci_fine_lower = y_fine - t_crit * se_fine;
ci_fine_upper = y_fine + t_crit * se_fine;
[corr_r,corr_p] = corr(x(:),y(:),'Rows','complete');

figure(1); set(gcf,'Color','w','Position',[0 100 360 360]); axes('Position',[0.20 0.36 0.40 0.40]); hold on; box on;
patch([x_fine; flipud(x_fine)],[ci_fine_lower; flipud(ci_fine_upper)], [0.75 0.75 0.75], 'EdgeColor','none', 'FaceAlpha',0.35);
plot(x_fine,y_fine,'Color',[0.35 0.35 0.35],'LineStyle','-','LineWidth',1.5);

for i = 1:length(x)
    h(i) = plot(x(i),y(i),'Marker','d','MarkerSize',8, ...
        'MarkerFaceColor',co(:,i),'MarkerEdgeColor','none', ...
        'LineStyle','none','LineWidth',1.6);
end

ax = gca;
set(ax,'FontSize',fontsi,'FontName',fontname, ...
    'Box','on','LineWidth',0.8, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'XLim',[-18 0],'XTick',-16:4:0, ...
    'YLim',[0 0.8],'YTick',0.1:0.2:0.8);

xlabel('\Delta AMOC (Sv)','FontSize',fontsi,'FontName',fontname);
ylabel('EEW (^oC)','FontSize',fontsi,'FontName',fontname);
ll = legend(h,modellist); ll.EdgeColor = 'none'; ll.Color = 'none'; ll.FontSize = fontsi-1; ll.Orientation = 'vertical'; ll.Position = [0.76 0.50 0 0];

%% map ----- tropical SST response in hosing experiments
im = 1:8;
data = nanmean(sst_diff(:,:,im),3);

clear tt;
for i = 1:size(sst_diff,1)
for j = 1:size(sst_diff,2)
    loc = squeeze(sst_diff(i,j,im)) .* data(i,j);
    tt(i,j) = length(find(loc >= 0));
end
end

figure(2); set(gcf,'Color','w','Position',[0 100 450 140]); axes('Position',[0.10 0.35 0.80 0.60]); hold on;
fontsi = 10; fontname = 'Arial';
m_proj('Equidistant Cylindrical','lon',[40 359],'lat',[-20 20]);

colorfinal = addcolorplus(312); colorfinal = colorfinal(1:4:end,:); colormap(colorfinal);
mm = 0.4;
[X,Y] = meshgrid(lonsst,latsst);
data = smoothdata(data,'movmean',5);
m_contourf(X,Y,data',[-10:0.1:3]*mm,'linestyle','none'); shading(gca,'interp'); caxis([-1 1]*mm);
c = colorbar('horizontal','position',[0.16 0.15 0.60 0.04]);
c.FontSize = fontsi; c.FontName = fontname; c.YTick = -0.8:0.2:0.8; cbarrow
text(2.2,-0.56,'^oC','FontSize',fontsi,'FontName',fontname,'HorizontalAlignment','left');

[XIN,YIN] = meshgrid(1:0.5:360,-20:0.1:20);
tt = interp2(X,Y,tt',XIN,YIN);
[Xs,Ys] = m_ll2xy(XIN,YIN);
mask = tt >= length(im);
stipple(Xs,Ys,mask,'density',120,'color',[0 0 0],'marker','.','markersize',1);

[X,Y] = meshgrid(lonsst,latsst);
lonrange = near1(lonsst,180):near1(lonsst,360-90); latrange = near1(latsst,-5):near1(latsst,5);
kuang = zeros(size(data)); kuang(lonrange,latrange) = 100;
m_contour(X,Y,kuang',[100 100],'linestyle','-','linecolor','k','linewi',0.5);

m_coast('patch',[0 0 0]+0.8,'edgecolor',[0 0 0]+0.8,'linewidth',1);
m_grid('box','on','linewidth',0.5,'tickLength',0.005,'linest','none','xtick',-360:60:360,'ytick',-80:10:90,'fontsize',fontsi,'fontname',fontname,'tickdir','out');
daspect([1 0.45 1]);
