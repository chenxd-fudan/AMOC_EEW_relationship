% Data availability note:
%   The original CMIP6 model outputs used in this study are too large to be included in the code-availability package.
%   Therefore, we provide the processed data needed to reproduce these figures.
%   The original CMIP6 data are publicly available from the official CMIP6/ESGF data portals.

%% scatter ----- relationships among AMOC, PMOC, EEW, T500, and ocean transport
clc; clear; close all;
modellist = {'ACCESS-CM2','ACCESS-ESM1-5','CanESM5','CanESM5-1','CAS-ESM2-0','CESM2','CESM2-WACCM','CIESM','CMCC-ESM2','CMCC-CM2-SR5','CNRM-CM6-1','CNRM-ESM2-1','EC-Earth3-CC','FGOALS-f3-L','FGOALS-g3','GFDL-ESM4','GISS-E2-1-G','GISS-E2-2-G','HadGEM3-GC31-LL','INM-CM4-8','INM-CM5-0','IPSL-CM6A-LR','MIROC-ES2L','MIROC6','MPI-ESM1-2-HR','MPI-ESM1-2-LR','MRI-ESM2-0','NorESM2-LM','NorESM2-MM','UKESM1-0-LL'}';
im = 1:30;

% load data % --------------------------
dir = '/Users/chenxiaodan/Documents/MOC/1. manuscript/Science/CodeAvailability/data/';
load ([dir,'moc_at_cmip6_hist_sst245.mat']);
load ([dir,'moc_ip_cmip6_hist_sst245.mat']);
load ([dir,'sst_global_cmip6_hist_sst245.mat']);

% set % --------------------------
clear co; co(:,1) = [1 1 1]*0.2;  co(:,2) = [1 1 1]*0.7;  co(:,3) = addcolorplus(264);  co(:,4) = addcolorplus(266);
co(:,5) = addcolorplus(260);  co(:,6) = addcolorplus(262);  co(:,7) = addcolorplus(256);  co(:,8) = addcolorplus(258);
co(:,9) = addcolorplus(252);  co(:,10) = addcolorplus(254); co(:,11) = addcolorplus(249); co(:,12) = addcolorplus(251);
co = co';
fontsi = 10; fontname = 'Arial';
alpha = 0.01;   % confidence level used for the regression band

% Calculate AMOC maximum index % --------------------------
latrange = near1(latq,0):near1(latq,65);
levrange = near1(levq,500):near1(levq,2000);
amoc_max_hist = squeeze(max(max(moc_at_hist(latrange,levrange,:),[],1),[],2));
amoc_max_fut  = squeeze(max(max(moc_at_fut (latrange,levrange,:),[],1),[],2));
amoc_max_diff = amoc_max_fut - amoc_max_hist;

% Calculate PMOC index % --------------------------
latrange = near1(latq,-30):near1(latq,-25);
levrange = near1(levmoc,500):near1(levmoc,1500);
data_moc = moc_ip_fut(:,:,im) - moc_ip_hist(:,:,im);
for i = 1:size(data_moc,3)
    pmoc_max_diff(i) = max(max(data_moc(latrange,levrange,i)));
end

% Calculate EEW index % --------------------------
lonrange = near1(lonsst,180):near1(lonsst,360-90); latrange = near1(latsst,-5):near1(latsst,5);
eqP = squeeze(nanmean(nanmean(sstfut(lonrange,latrange,:) - ssthist(lonrange,latrange,:),1),2));
lonrange = near1(lonsst,130):near1(lonsst,360-90); latrange = near1(latsst,-20):near1(latsst,20);
tropicP = squeeze(nanmean(nanmean(sstfut(lonrange,latrange,:) - ssthist(lonrange,latrange,:),1),2));
eew = eqP - tropicP;

% T500 index % --------------------------
T500_diff = [0.590553595180740 0.644057974163204 0.441495716304888 0.499882103436674 0.493047283543945 0.757518307406128 0.825084671474789 0.767405050754440 0.357205698419049 0.311607314209346 0.614483734366774 0.619030288344554 0.629478695213334 0.629846166216035 0.696396770420157 0.545821018292373 0.587092875788116 0.635700077302967 0.703183013017250 0.360780473038650 0.357552297601323 0.605845994228086 0.811538717661535 0.569201145195680 0.527629618058368 0.657996329156526 0.806811051473914 0.815454103464260 0.756948484911131 0.605370736183660];

%% scatter ----- EEW index vs delta AMOC
x = amoc_max_diff(:);
y = eew(:);
plot_scatter_regression(x,y,co,fontsi,fontname,alpha, ...
    '\Delta AMOC (Sv)','EEW (^oC)',[-18 0],-16:4:0,[0 0.8],0.1:0.2:0.8);

%% scatter ----- delta PMOC vs delta AMOC
x = amoc_max_diff(:);
y = pmoc_max_diff(:);
plot_scatter_regression(x,y,co,fontsi,fontname,alpha, ...
    '\Delta AMOC (Sv)','\Delta PMOC (Sv)',[-18 0],-16:4:0,[0 11],0:3:12);

%% scatter ----- delta PMOC vs T500
x = pmoc_max_diff(:);
y = T500_diff(:);
plot_scatter_regression(x,y,co,fontsi,fontname,alpha, ...
    '\Delta PMOC (Sv)','\Delta T500 (^oC)',[0 11],0:3:12,[0.2 1],0.2:0.2:1);

%% scatter ----- delta PMOC vs EEW index
x = pmoc_max_diff(:);
y = eew(:);
plot_scatter_regression(x,y,co,fontsi,fontname,alpha, ...
    '\Delta PMOC (Sv)','EEW (^oC)',[0 11],0:3:12,[0 0.8],0.1:0.2:0.8);

%% scatter ----- delta AMOC vs 1500-3000 m ocean volume transport
% Choose 'zonal' or 'meridional' according to the transport to be plotted.
transport_type = 'meridional';

if strcmp(transport_type,'zonal')
    load ([dir,'OHVx_1500mto3000m_global_cmip6_hist_sst245.mat']);
    % lonrange = [near1(lonsst,45):near1(lonsst,75), near1(lonsst,170):near1(lonsst,180+30)];
    lonrange = near1(lonsst,-40):near1(lonsst,-20);   
    latrange = near1(latsst,-24):near1(latsst,-24);
    ylabel_text = '\Delta Zonal transport (Sv)';
     ytick_use = -20:2:20;
else
    load ([dir,'OHVy_1500mto3000m_global_cmip6_hist_sst245.mat']);
    lonrange = near1(lonsst,-15):near1(lonsst,-15);
    latrange = near1(latsst,-48):near1(latsst,-20);
    ylabel_text = '\Delta Meridional transport (Sv)';
     ytick_use = -20:2:20;
end

data = fut - hist;
data = cat(1,data,data);
sv = squeeze(nansum(nansum(data(lonrange,latrange,:),1),2));
sv(16) = NaN;

x = amoc_max_diff(:);
y = sv(:);
plot_scatter_regression(x,y,co,fontsi,fontname,alpha, ...
    '\Delta AMOC (Sv)',ylabel_text,-16:4:16,ylim_use,ytick_use);

%% local function % --------------------------
function plot_scatter_regression(x,y,co,fontsi,fontname,alpha,xlab,ylab,xlim_use,xtick_use,ylim_use,ytick_use)

loc = isfinite(x) & isfinite(y);
x = x(loc); y = y(loc);

X = [ones(size(x)), x];
[b,~,r,~,stats] = regress(y,X,alpha);
x_fine = linspace(min(x)-5,max(x)+5,100)';
X_fine = [ones(size(x_fine)), x_fine];
y_fine = X_fine * b;

n = length(y); p = length(b); df = n - p;
sigma2_hat = sum(r.^2) / df;
se_fine = sqrt(sigma2_hat * sum((X_fine / (X' * X)) .* X_fine, 2));
t_crit = tinv(1 - alpha/2, df);
ci_fine_lower = y_fine - t_crit * se_fine;
ci_fine_upper = y_fine + t_crit * se_fine;
[corr_r,corr_p] = corr(x,y,'Rows','complete');

figure; set(gcf,'Color','w','Position',[100 100 360 360]);
axes('Position',[0.20 0.34 0.43 0.43]); hold on; box on;
patch([x_fine; flipud(x_fine)],[ci_fine_lower; flipud(ci_fine_upper)], [0.75 0.75 0.75], 'EdgeColor','none', 'FaceAlpha',0.35);
plot(x_fine,y_fine,'Color',[0.35 0.35 0.35],'LineStyle','-','LineWidth',1.5);

for i = 1:length(x)
    if i <= 12
        marker = 's'; ic = i;
    elseif i <= 24
        marker = '^'; ic = i - 12;
    else
        marker = 'o'; ic = i - 24;
    end
    plot(x(i),y(i),marker,'MarkerSize',8,'MarkerFaceColor','none','MarkerEdgeColor',co(ic,:), ...
        'LineStyle','none','LineWidth',1.4);
end

ax = gca;
set(ax,'FontSize',fontsi,'FontName',fontname,'Box','on','LineWidth',0.8, ...
    'TickDir','out','TickLength',[0.012 0.012], ...
    'XLim',xlim_use,'XTick',xtick_use,'YLim',ylim_use,'YTick',ytick_use);
xlabel(xlab,'FontSize',fontsi,'FontName',fontname);
ylabel(ylab,'FontSize',fontsi,'FontName',fontname);

end
