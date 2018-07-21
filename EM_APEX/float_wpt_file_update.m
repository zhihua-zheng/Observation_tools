%function to edit a .gpx file of the latest em-apex float positions and
%drifter positions
function float_wpt_file_update(new_positions,ema_lats,ema_lons,ema_time)

% gpx_wpt_file_location=('Z:\docs\science_docs\Float_Drifter_Current.gpx');
gpx_wpt_file_location=('/Volumes/science_docs/Float_Drifter_Current.gpx');


%open gpx file
gpx_file=fopen(gpx_wpt_file_location,'r+');

EndOfFile=0;
pointer=1;
float_numbers={'7488-', '7801-', '7802-', '7803-', '7804-', '7805-','svp50-','svp70-'};
%file needs to be in order of float number (7488, 7801, 7802, 7803, 7804,
%7805, svp50, svp70)

while EndOfFile==0
    beginning_of_line=ftell(gpx_file);
    current_line=fgetl(gpx_file);
    if current_line(1:6)=='  <wpt'
        if new_positions(pointer)==1
            fseek(gpx_file,beginning_of_line+2,'bof');
            fprintf(gpx_file,'<wpt lat="%12.9f" lon="%13.9f">\n',[ema_lats(pointer) ema_lons(pointer)]);
            fseek(gpx_file,beginning_of_line,'bof');
            current_line=fgetl(gpx_file);
            wpt_end=0;

            while wpt_end==0
                beginning_of_line=ftell(gpx_file);
                current_line=fgetl(gpx_file);
                    if current_line(6:9)=='name'
                        if current_line(11:13)=='svp'
                            fseek(gpx_file,beginning_of_line+4,'bof');
                            fprintf(gpx_file,'<name>%s%s</name>\n',[float_numbers{pointer} datestr(ema_time(pointer),'HH:MM')]);
                        else
                            fseek(gpx_file,beginning_of_line+4,'bof');
                            fprintf(gpx_file,'<name>%s%s</name>\n',[float_numbers{pointer} datestr(ema_time(pointer),'HH:MM')]);
                        end
                        fseek(gpx_file,beginning_of_line,'bof');
                        current_line=fgetl(gpx_file);
                    elseif current_line(6:9)=='desc'
                        fseek(gpx_file,beginning_of_line+4,'bof');
                        fprintf(gpx_file,'<desc>%s GMT</desc>\n',datestr(ema_time(pointer),'mmddyyyy HHMM'));
                        fseek(gpx_file,beginning_of_line,'bof');
                        current_line=fgetl(gpx_file);
                    elseif current_line(16)=='g'
                        fseek(gpx_file,beginning_of_line,'bof');
                        fprintf(gpx_file,'');
                        fseek(gpx_file,beginning_of_line,'bof');
                        current_line=fgetl(gpx_file);
                    elseif current_line(5:6)=='</'
                        wpt_end=1;
                    end
                
            end
            pointer=pointer+1;
        else
            pointer=pointer+1;
        end
            
    end
    
    EndOfFile=feof(gpx_file);

end

fclose(gpx_file);
