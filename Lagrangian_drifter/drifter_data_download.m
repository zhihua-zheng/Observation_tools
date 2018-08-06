%% drifter_data_download

function [svp50,svp70]=drifter_data_download()

% automatically download Lagrangian drifter data from webpage

% by Zhihua Zheng (UW-APL), July 17 2018

%% scraping from url

url_50 = 'http://out-gdpsio.ucsd.edu/cgi-bin/projects/rc-lien/drifter-test.py?platform_id=300234065618130';
url_70 = 'http://out-gdpsio.ucsd.edu/cgi-bin/projects/rc-lien/drifter-test.py?platform_id=300234065618150';

options = weboptions('Username','rc-lien','Password','svp50/70','Timeout',20);
data_50 = webread(url_50, options);
data_70 = webread(url_70, options);

%% data munging

    % head = data_50(1:230);

    rows_50 = strfind(data_50,'</br>');
    rows_70 = strfind(data_70,'</br>');

    drifter_50 = cell(length(rows_50)-1,1);
    drifter_70 = cell(length(rows_70)-1,1);

    for i = 1:12:length(rows_50)-1

        drifter_50(i) = {data_50(rows_50(i)+5:rows_50(i+1)-1)};
    end
    
    % remove empty content
    drifter_50 = drifter_50(~cellfun(@isempty, drifter_50));


    for i = 1:12:length(rows_70)-1

        drifter_70(i) = {data_70(rows_70(i)+5:rows_70(i+1)-1)};  
    end
    
    % remove empty content
    drifter_70 = drifter_70(~cellfun(@isempty, drifter_70));


%% format the screened lat, lon, time info

project_start = datenum(2018,07,15,17,00,00);

% extract from drifter_50
svp50 = zeros(3,length(drifter_50));
for i = 1:length(drifter_50)
    
    svp50(1,i) = datenum(drifter_50{i}(17:35),'yyyy-mm-dd HH:MM:SS'); % date string
    svp50(2,i) = str2double(drifter_50{i}(37:45)); % lat
    svp50(3,i) = str2double(drifter_50{i}(47:55)); % lon
end

% extract from drifter_70
svp70 = zeros(3,length(drifter_70));
for i = 1:length(drifter_70)
    
    svp70(1,i) = datenum(drifter_70{i}(17:35),'yyyy-mm-dd HH:MM:SS'); % date string
    svp70(2,i) = str2double(drifter_70{i}(37:45)); % lat
    svp70(3,i) = str2double(drifter_70{i}(47:55)); % lon
end


% discard old record before project_start date
early_points = svp50(1,:)<project_start;
svp50(:,early_points) = [];
drifter_50(early_points) = [];

early_points = svp70(1,:)<project_start;
svp70(:,early_points) = [];
drifter_70(early_points) = [];

% flip the order of data
svp50 = fliplr(svp50);
svp70 = fliplr(svp70);


%% write into txt file

tmp1 = svp50';
tmp2 = svp70';
save('/Volumes/science_docs/emapex/svp.mat','tmp1','tmp2')

% fileID = fopen('/Volumes/science_docs/drifter/drifter_positions_test.txt','w');
% formatSpec = '%s \n';
% rows = min(length(drifter_50),length(drifter_70));
% 
% % fprintf(fileID,formatSpec,heading);
% % fprintf(fileID,formatSpec,'');
% 
% for i = 1:rows
%     fprintf(fileID,formatSpec,string(drifter_50(i)));
%     fprintf(fileID,formatSpec,string(drifter_70(i)));
%     fprintf(fileID,formatSpec,'');
% end
% 
% fclose(fileID);

end





