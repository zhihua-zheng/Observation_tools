%SVP drifter position parser - RC Lien - submesoscale string oceanus
function [svp50,svp70]=get_drifter_data()

%Platform-ID,Timestamp(UTC),GPS-Latitude(deg),GPS-Longitude(deg),SST(degC),
%SLP(mB),Battery(volts),Drogue(Count),GPS-FixDelay,GPS-TTFF,GPS-HDOP,
%SBD-Transmit-Delay,SBD-Retries,Hull-Humidity(%),Hull-Temperature(degC),Hull-Pressure(mB)

%open file
%read in platform-id, timestamp(utc), gps lat (decimal degrees), gps lon (decimal degrees)
%close file

drifter_file=fopen('/Volumes/science_docs/drifter/drifter_positions.txt');
drifter_data=textscan(drifter_file,'%s %s %f %f %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s','delimiter',',');
fclose(drifter_file);

svp50=[];
svp70=[];

for i=1:length(drifter_data{1})
    if str2num(drifter_data{1,1}{i})==300234065618130
        svp50(end+1,1)=datenum(drifter_data{1,2}{i},'yyyy-mm-dd HH:MM:SS');
        svp50(end,2)=drifter_data{1,3}(i); %lat
        svp50(end,3)=drifter_data{1,4}(i); %lon
       
    elseif str2num(drifter_data{1,1}{i})==300234065618150
        svp70(end+1,1)=datenum(drifter_data{1,2}{i},'yyyy-mm-dd HH:MM:SS');
        svp70(end,2)=drifter_data{1,3}(i); %lat
        svp70(end,3)=drifter_data{1,4}(i); %lon
    end
end

svp50=sortrows(svp50);
svp70=sortrows(svp70);
