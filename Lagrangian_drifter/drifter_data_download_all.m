%% drifter_data_download_all


% download Lagrangian drifter data from webpage

% by Zhihua Zheng (UW-APL), August 6 2018

%% scraping from url

url_50 = 'http://out-gdpsio.ucsd.edu/cgi-bin/projects/rc-lien/drifter-test.py?platform_id=300234065618130';
url_70 = 'http://out-gdpsio.ucsd.edu/cgi-bin/projects/rc-lien/drifter-test.py?platform_id=300234065618150';

options = weboptions('Username','rc-lien','Password','svp50/70','Timeout',20);
data_50 = webread(url_50, options);
data_70 = webread(url_70, options);

%% data munging

head = data_50(1:230);
vars = strsplit(head,',');

rows_50 = strfind(data_50,'</br>');
rows_70 = strfind(data_70,'</br>');

drifter_50 = cell(length(rows_50)-1,length(vars));
drifter_70 = cell(length(rows_70)-1,length(vars));

for i = 1:length(rows_50)-1

    tmp = data_50(rows_50(i)+5:rows_50(i+1)-1);
    drifter_50(i,:) = strsplit(tmp,',');
end    


for i = 1:length(rows_70)-1

    tmp = data_70(rows_70(i)+5:rows_70(i+1)-1); 
    drifter_70(i,:) = strsplit(tmp,',');
end
    
%% format the data type

project_start = datenum(2018,07,15,17,00,00);

for i = 1:length(drifter_50)
    
   drifter_50{i,2}  = datenum(drifter_50{i,2},'yyyy-mm-dd HH:MM:SS'); % date string
   
    for j = 3:16
        drifter_50{i,j}  = str2double(drifter_50{i,j}); 
    end
end

for i = 1:length(drifter_70)
    
   drifter_70{i,2}  = datenum(drifter_70{i,2},'yyyy-mm-dd HH:MM:SS'); % date string
   
    for j = 3:16
        drifter_70{i,j}  = str2double(drifter_70{i,j}); 
    end
end


% discard old record before project_start date
early_points = cell2mat(drifter_50(:,2))<project_start;
drifter_50(early_points,:) = [];

early_points = cell2mat(drifter_70(:,2))<project_start;
drifter_70(early_points,:) = [];

% flip the order of data
svp50 = flipud(drifter_50);
svp70 = flipud(drifter_70);

% add variable name
svp50 = [vars;svp50];
svp70 = [vars;svp70];

save('drifter_data','svp50','svp70');

