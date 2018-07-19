% get latest GPS and heading NMEA strings from ship's UDP feed

function [nmea_line]=get_GPS_NMEA_udp()

remotehost='10.128.240.152';
remoteport=52722;
localport=55555;

ship_gps_udp_feed=udp(remotehost,remoteport,'localport',localport);
fopen(ship_gps_udp_feed);
nmea_line=scanstr(ship_gps_udp_feed,'/r');
fclose(ship_gps_udp_feed);

%had issues with input buffer and lag so opted to open and close UDP object
%every time a new position is requested