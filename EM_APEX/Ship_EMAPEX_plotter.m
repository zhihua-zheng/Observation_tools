%% ship and em-apex plotter

% Automatically update the position of ship, EM-Apex floats and Lagrangian 
% drifters and plot the track and position of them in one map, along with 
% the designed survey route.

% from Ryan Newell, APL/OPD, July 16 2018
% modified by Zhihua Zheng, UW-APL, July 2018

%--------------------------------------------------------------------------
%% Pre setup

% ensure all connections are closed
% out=instrfind;
% if is(out)
%     fclose(out);
% end

clear

% emapex_matfile_location='Z:\docs\science_docs\emapex\GPS.mat';
% gpxfile='Z:\docs\science_docs\Current_box_survey.gpx';
emapex_matfile_location = '/Volumes/science_docs/emapex/GPS.mat';
gpxfile = '/Volumes/science_docs/Current_box_survey.gpx';

% open figure
f2 = figure;

% initialize ship variables
ship_lat = zeros(86400,1);
ship_lon = zeros(86400,1);
ship_inx = 0; % index for the times ship info has been updated

% initialize float/drifter variables
new_positions = [1,1,1,1,1,1,1,1];
latest_emapex_lats = [0,0,0,0,0,0,0,0];
latest_emapex_lons = [0,0,0,0,0,0,-126.504535000,-126.504535000];
latest_emapex_calls = [0,0,0,0,0,0,0,0];
total_emapex_calls = 0;
previous_number_of_calls = 0;

% project start time
project_start=datenum(2018,07,15,17,00,00); 

AA = 0; % loop condition
it = 1; % number for loop iterations

%% the loop to update info

while AA==0
    
    % check ship variables
    if ship_lat(end) > 0
        
        % shift first day ship track data to the right for rewritting 
        % when the array gets too large
        ship_lat = circshift(ship_lat,-17280);
        ship_lon = circshift(ship_lon,-17280);
        ship_lat(end-17279:end) = 0;
        ship_lon(end-17279:end) = 0;
        ship_inx = ship_inx - 17279;
    end
    
    
    % get latest ship GPS position and survey route  
    if (mod(it,6)==0 || it==1)  % update the ship info every 6 iterations
       
        % get track waypoints
       survey_track = gpxread(gpxfile);
        
       ship_inx = ship_inx + 1;
       nmea_feed = get_GPS_NMEA_udp;

       if length(nmea_feed)==3
          for i = 1:3
              if strcmp('$GPGGA',nmea_feed{i}(1:6))==1

                 Cgps = textscan(nmea_feed{i},'%s','delimiter',','); 
                 GPm = Cgps{1};
                 ship_gps_time = GPm{2};

                 if GPm{4}=='S'
                    n_s_sign = -1;
                 else
                    n_s_sign = 1;
                 end

                 ship_lat_Dmin = GPm{3};
                 ship_lat_d = str2double(ship_lat_Dmin(1:2));
                 ship_lat_min = str2double(ship_lat_Dmin(3:end));
                 ship_lat(ship_inx) = n_s_sign*(ship_lat_d+ship_lat_min./60);


                 if GPm{6}=='W'
                    e_w_sign = -1;
                 else
                    e_w_sign = 1;
                 end
                 ship_lon_Dmin = GPm{5};
                 ship_lon_d = str2double(ship_lon_Dmin(1:3));
                 ship_lon_min = str2double(ship_lon_Dmin(4:end));
                 ship_lon(ship_inx) = e_w_sign*(ship_lon_d+ship_lon_min./60);


                 elseif strcmp('$HEHDT',nmea_feed{i}(1:6))==1

                    Cgps = textscan(nmea_feed{i},'%s','delimiter',','); 
                    GPm=Cgps{1};
                    %$HEHDT,63.54,T*31

                    ship_heading=str2double(GPm{2});  

              end %ignore $GPRMC for now
           end
       else
            continue %if a full NMEA string wasn't recieved go back to beginning
       end
    end
    
   
    % get all EM-APEX positions from project

    % ema_gps=fopen('Z:docs\science_docs\emapex\ema-gps.txt');
    ema_gps = fopen('/Volumes/science_docs/emapex/ema-gps.txt');
    ema = textscan(ema_gps,...
        '%*s %f %19c %f %f %*s %f %f %*s %*s %*s %*s','HeaderLines',16500);
    fclose(ema_gps);
    
    fnum_all = (ema{1})';
    datetimestr = string(ema{2});
    dnum_all = datenum(char(datetimestr),'yyyy/mm/dd HH:MM:SS');
    lats_all = (ema{3}+ema{4}/60)';
    lons_all = (ema{5}+ema{6}/60)'; % new bug!!
    
    % pick out the data for this project
    start_inx = find(dnum_all > project_start,1,'first');
    emapex_mlds = dnum_all(start_inx:end)';
    emapex_fnum = fnum_all(start_inx:end);
    emapex_lats = lats_all(start_inx:end);
    emapex_lons = -lons_all(start_inx:end);
    
    % pick out specific floats used
    project_subset = find...
        (emapex_fnum>= 7801 & emapex_fnum<=7805 | emapex_fnum==7488);
    
    emapex_fnum = emapex_fnum(project_subset);
    emapex_lats = emapex_lats(project_subset);
    emapex_lons = emapex_lons(project_subset);
    emapex_mlds = emapex_mlds(project_subset);
    
    total_emapex_calls = length(emapex_fnum);
    
    
    % get drifter data - format datenum, lat, lon
    
    %[svp50,svp70]=get_drifter_data();
    %svp50=svp50';
    %svp70=svp70';
    
    if (mod(it,600)==0 || it==1)  % 600 ~ 30mins, 3s/loop in average
       
        % new function, call every half an hour approximately 
        [svp50,svp70]=drifter_data_download();    
    end
    
    
    % find lat and lon window capturing ship and all float positions
    all_lats = horzcat(emapex_lats,ship_lat(ship_inx),svp50(2,:),...
        svp70(2,:),survey_track.Latitude);
    all_lons = horzcat(emapex_lons,ship_lon(ship_inx),svp50(3,:),...
        svp70(3,:),survey_track.Longitude);
    latlim = [min(all_lats)-.03 max(all_lats)+.03];
    lonlim = [min(all_lons)-.03 max(all_lons)+.03];
    
    % set figure scope limit
    HA = axesm('UTM','MapLatLimit',latlim,'MapLonLimit',lonlim,'grid','off');
    hold(HA,'on')
    
    
    % update the ship and route plots every 6 iterations
    if (mod(it,6)==0 || it==1)  
        
        % plot survey waypoints and ship position
       if exist('ship_track','var')
            delete(ship_track)
            delete(box_survey_track)
            delete(latest_ship_position)
            delete(ship_heading_arrow)
       end
       
       % survey route
       box_survey_track = plotm(survey_track.Latitude,survey_track.Longitude,...
            'LineStyle','-.','Color',[.62 .62 .62],'linewidth',3);
       hold on
       
       % ship track
       ship_track = plotm(ship_lat,ship_lon,'-b','linewidth',.07);
       hold on 
       
       % ship heading arrow
       [lat_heading_track,lon_heading_track] = track1(ship_lat(ship_inx),...
            ship_lon(ship_inx),ship_heading,0.01,'degrees');
       delta_lat = lat_heading_track(end)-lat_heading_track(1);
       delta_lon = lon_heading_track(end)-lon_heading_track(1);

       ship_heading_arrow = quiverm(lat_heading_track(1),lon_heading_track(1)...
            ,delta_lat,delta_lon,'linewidth',3,'MaxHeadSize',0.5); 
       hold on
       
       % current ship position
       latest_ship_position = plotm(ship_lat(ship_inx),ship_lon(ship_inx),...
                               '-mo','MarkerEdgeColor',[.2 .3 .4],...
                               'MarkerFaceColor',[.49 1 .63],'MarkerSize',10);
       hold on       
    end
    
    
    
    % update EM-APEX float info
    if total_emapex_calls>previous_number_of_calls || previous_number_of_calls==0
        
        % plot EM-APEX positions
        if exist('emapex_plotted_positions','var')
            delete(emapex_plotted_positions)
            delete(emapex_plotted_text)
            delete(emapex_last_plotted_positions)
        end
     
        % initialize the float plotting handles
        emapex_plotted_positions = gobjects(1,6);
        emapex_plotted_text = gobjects(1,6);
        emapex_last_plotted_positions = gobjects(1,6);
        
        fids = unique(emapex_fnum);
        
        for i = 1:length(fids)
            
            fid = fids(i);
            ii = find(emapex_fnum==fid);
            latest_call = max(ii);
            
            latest_emapex_lats(i) = emapex_lats(latest_call);
            latest_emapex_lons(i) = emapex_lons(latest_call);
            latest_emapex_calls(i) = emapex_mlds(latest_call);
            
            % historic positions
            emapex_plotted_positions(i) = plotm(emapex_lats(ii),emapex_lons(ii),...
                ':.','Color',[.9 .6 0],'markersize',10,'linewidth',.4);
            hold on
            
            % text lable
            emapex_plotted_text(i)=textm(latest_emapex_lats(i),...
                latest_emapex_lons(i)+0.002,char(strcat(num2str(fid),'-  ',string(datestr...
                (latest_emapex_calls(i),'HH:MM')))));
            hold on
            
            % lastest positions
            emapex_last_plotted_positions(i)=plotm(emapex_lats(latest_call),...
                emapex_lons(latest_call),':*','Color',[.4 .2 .6],'markersize',8);
            hold on 
        end
        
        % update *.gpx file for openCPN
        float_wpt_file_update(new_positions,latest_emapex_lats,...
            latest_emapex_lons,latest_emapex_calls);            
    end
    previous_number_of_calls = total_emapex_calls;
    
    
    
    % update the drifter info when there is a new grabbing from web
    if (mod(it,200)==0 || it==1)
        
        % update the *.gpx file whenever there is a new drifter position
        latest_emapex_lats(7) = svp50(2,end);
        latest_emapex_lons(7) = svp50(3,end);
        latest_emapex_calls(7) = svp50(1,end);
        latest_emapex_lats(8) = svp70(2,end);
        latest_emapex_lons(8) = svp70(3,end);
        latest_emapex_calls(8) = svp70(1,end);
        
        float_wpt_file_update(new_positions,latest_emapex_lats,...
            latest_emapex_lons,latest_emapex_calls);
        
        % plot drifters
        if exist('drifter1','var')
            delete(drifter1)
            delete(drifter2)
            delete(drifter1last)
            delete(drifter2last)
            delete(drifter1text)
            delete(drifter2text)
        end
        
        % historic positions
        drifter1 = plotm(svp50(2,:),svp50(3,:),':.r','markersize',10,'linewidth',.4);
        hold on

        drifter2 = plotm(svp70(2,:),svp70(3,:),':.r','markersize',10,'linewidth',.4);
        hold on

        % drifter1=plotm(svp50(2,:),svp50(3,:),':r','linewidth',.3);
        % drifter2=plotm(svp70(2,:),svp70(3,:),':r','linewidth',.3);
        % cmocean('matter')
        % drifter1_s=scatterm(svp50(2,:),svp50(3,:),15,svp50(1,:),'filled');
        % drifter2_s=scatterm(svp70(2,:),svp70(3,:),15,svp70(1,:),'filled');
        
        % lastest postion
        drifter1last = plotm(svp50(2,end),svp50(3,end),'^r','markersize',8);
        hold on

        drifter2last = plotm(svp70(2,end),svp70(3,end),'^r','markersize',8);
        hold on

        % text label
        drifter1text = textm(svp50(2,end),svp50(3,end)+0.002,...
            ['SVP50-' datestr(svp50(1,end),'HH:MM')]);
        hold on

        drifter2text = textm(svp70(2,end),svp70(3,end)+0.002,...
            ['SVP70-' datestr(svp70(1,end),'HH:MM')]);
        hold on 
    end
    
   
    
    % print updated time on command window
    fprintf(1,'updated %s UTC\n',ship_gps_time);
    
    % print time on figure
    if exist('TM1','var')
        clmo(TM1);
    end
    
    TM1 = textm(latlim(1)+0.04,lonlim(1)+0.03,...
        ['updated at ' ship_gps_time ' UTC'],'fontname',...
        'computer modern','Interpreter','latex','fontsize',12);
    hold on 
    
    % print out the ruler
    if exist('ruler','var')
       delete(ruler)
    end
    
    xlim = get(HA,'XLim');
    ylim = get(HA,'YLim');
    scaleruler('XLoc',xlim(2)-6500,'YLoc',ylim(2)-8000,'fontname',...
        'times','fontsize',10)
    ruler = handlem('scaleruler');
    
    pause(5)
    it = it + 1; % count the number of iterations, 1 ~ 5 seconds
end