%% visualize_met

% script to visualize the raw meteorological data time series.

% Zhihua Zheng, UW-APL, July 2018

%% read data

main_dir = '/Volumes/science_docs/Met';

load([main_dir,'/','MetData']);

sw = MetData.LWSW.SW;
lw = MetData.LWSW.LW;
time_rad = MetData.LWSW.Jday;

rh = MetData.MET.RH;
p_air = MetData.MET.hPa;
t_air = MetData.MET.AT;
time_air = MetData.MET.Jday;

tw_speed = MetData.Bow_Wind_True_Gyro.TW_Speed;
tw_dir = MetData.Bow_Wind_True_Gyro.TW_Dir;
time_tw = MetData.Bow_Wind_True_Gyro.Jday;

tw_speed(tw_speed>100) = NaN;
tw_dir(tw_dir>360) = NaN;

small_dir = find(tw_dir<=80 & tw_dir>=0);
tw_dir(small_dir) = tw_dir(small_dir) + 360;

%% plot

% ------------  
figure('position', [0, 0,650, 1200])
subplot(7,1,1)
line(time_rad,sw,'LineWidth',.2,'Color',[.8 .5 .4])
  box on
  datetick('x','mm/dd')
  ylabel('short wave radiation ($$W/m^2$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern',...
      'TickLabelInterpreter','latex')

  
subplot(7,1,2)
line(time_rad,lw,'LineWidth',.2,'Color',[.7 .3 .6])
line(time_rad,zeros(size(time_rad)),'LineStyle','--','LineWidth',.4,'Color',[.3 .4 .3])
  box on
  datetick('x','mm/dd')
  ylabel('long wave radiation ($$W/m^2$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern','XTickLabel',[],...
      'TickLabelInterpreter','latex','YAxisLocation','right')
 
  
% ------------
subplot(7,1,3)
line(time_air,rh,'LineWidth',.2,'Color',[.1 .7 .2])
  box on
  datetick('x','mm/dd')
  ylabel('relative humidity ($$\%$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern',...
      'TickLabelInterpreter', 'latex')
 
subplot(7,1,4)
line(time_air,p_air,'LineWidth',.2,'Color',[.5 .3 .8])
  box on
  datetick('x','mm/dd')
  ylabel('barometric pressure ($$hPa$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern','XTickLabel',[],...
      'TickLabelInterpreter','latex','YAxisLocation','right')
  
subplot(7,1,5)
line(time_air,t_air,'LineWidth',.2,'Color',[.9 .4 .2])
  box on
  datetick('x','mm/dd')
  ylabel('air temperature ($$^{o}C$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern',...
      'TickLabelInterpreter', 'latex')
    
% ------------ 
subplot(7,1,6)
line(time_tw,tw_speed,'LineWidth',.2,'Color',[.8 .4 .5])
  box on
  datetick('x','mm/dd')
  ylabel('wind speed ($$knot$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern','XTickLabel',[],...
      'TickLabelInterpreter','latex','YAxisLocation','right')

subplot(7,1,7)
scatter(time_tw,tw_dir,.5,'MarkerFaceColor',[.4 .7 .2])
line(time_tw,ones(size(time_tw))*360,'LineStyle','--','LineWidth',.4,'Color',[.3 .4 .3])
  box on
  datetick('x','mm/dd')
  ylabel('wind direction ($$degree$$)', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  xlabel('time', 'fontname', 'computer modern', 'fontsize', 8,'Interpreter', 'latex')
  setDateAxes(gca,'XLim',[datenum(2018,7,9,16,0,0) datenum('July 25, 2018')],...
      'fontsize',8,'fontname','computer modern','YLim',[0 450],...
      'TickLabelInterpreter','latex')
  
export_fig([main_dir,'/met_time_series'],'-pdf','-transparent','-painters')  

