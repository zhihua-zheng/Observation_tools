%% make_met
function MetData = make_met(main_dir)

% Script to read scattered meterological data and concatenate into one file

% Please specify main_dir if necessary (e.g. Windows OS)!
% Default main_dir is in the form of Mac OS for shared folder 'smb://ark01'

% Zhihua Zheng, UW-APL, July 2018

% -------------------------------------------------------------------------
%% set path and variables to save data

if (~exist('main_dir', 'var'))    
   main_dir = '/Volumes/science_docs/Met';
   slash = '/';
else 
    slash = '\';
end

folder = {'ASHTECH_GGA','Bow_Wind_Relative','Bow_Wind_True_ADU5',...
    'Bow_Wind_True_Gyro','Flowthrough','LWSW','MET'};

char_folder = char(folder); % cell array to character array

MetData = struct();

%% 

for i = 1:length(folder)
    
    data_dir = strcat(main_dir,slash,char_folder(i,:));
    dinfo = dir(fullfile(data_dir,'*.mat'));
    num_files = length(dinfo);
    filenames = fullfile(data_dir,{dinfo.name});
    
    % get the field list for this type of file
    tmp = load(filenames{1});
    field = fieldnames(tmp);
    
    var = cell(num_files, length(field));
    
    % read and store daily data
    for j = 1:num_files
        
        tmp = load(filenames{j});
        
        for k = 1:length(field)
            
            tmp_field = tmp.(field{k});
            % make sure it's all one column data
            if size(tmp_field,1) == 1
                tmp_field = tmp_field';
            end
            var(j,k) = {tmp_field};
        end       
    end 
    
    % concatenate vertically in cell
    var = cellfun(@(col) vertcat(col{:}),num2cell(var, 1),'UniformOutput',false);
    
    % use an alias for field 'Jday' to avoid confusion
    
%     if ismember('Jday',field)      
%         field = replace(field,'Jday',[folder(i,:),'_','Jday']);
%     end
        
 
    for k = 1:length(field)
        
        MetData.(folder{i}).(field{k}) = cell2mat(var(k));
    end
    
end

save([main_dir,slash,MetData_',datestr(now,'mm/dd')],'MetData');


