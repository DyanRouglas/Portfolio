% This script loops through all subjects and calculates heart rate,
% respiration, and RMSSD for all scans within each subject folder. It
% outputs this data to a csv file.

directory = '/Volumes/data-CC1486-Psychiatry/Physio_MM';
folders = dir(directory);
output = '/Users/DyanRouglas/Documents/Yale_data/PulseOximeter/';

% read in previous pulse ox file
%% Initialize variables.
filename = '/Users/DyanRouglas/Documents/Yale_data/PulseOximeter/PulsOxRMSSD_CutFinal.csv';
delimiter = ',';
startRow = 2;

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[3,4,5,6,7]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, [3,4,5,6,7]);
rawStringColumns = string(raw(:, [1,2]));


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Make sure any text containing <undefined> is properly converted to an <undefined> categorical
idx = (rawStringColumns(:, 2) == "<undefined>");
rawStringColumns(idx, 2) = "";

%% Create output variable
prev_pulse = table;
prev_pulse.ScanID = rawStringColumns(:, 1);
prev_pulse.ScanType = categorical(rawStringColumns(:, 2));
prev_pulse.ScanLength = cell2mat(rawNumericColumns(:, 1));
prev_pulse.Respiration = cell2mat(rawNumericColumns(:, 2));
prev_pulse.HR = cell2mat(rawNumericColumns(:, 3));
prev_pulse.RMSSD = cell2mat(rawNumericColumns(:, 4));
prev_pulse.SignalQuality = cell2mat(rawNumericColumns(:, 5));

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R idx;
% skip = 0;
count = 1;
% Keep track of instances where the number of resp files
% does not equal the number of pulse files
unevenFiles = 0;

for i = 1:length(folders)
    
    % Construct file path to pulse and resp files
    file = strcat(directory, '/', folders(i).name);
    
    filepattern = fullfile(file,'*RESP.log') ;
    files = dir(filepattern);
    
    filepatternPuls = fullfile(file, '*PULS.log');
    filesPuls = dir(filepatternPuls);
    
    % Even out files if different number of pulse and resp files
    if (length(files) > length(filesPuls))
       files(1) = [];
       unevenFiles = unevenFiles + 1;
    elseif (length(files) < length(filesPuls))
        filesPuls(1) = [];
        unevenFiles = unevenFiles + 1;
    end
    
    
    if isempty(files)
        continue
    end
    
    for f = 1:length(files)
        %% Process Respiration first
        
        filename = strcat(file, '/', files(f).name);
        name = cellstr(filename(43:48));
        
        % skip if already processed 
        if ismember(name, prev_pulse.ScanID) == 1
            continue
        end
        
        % Read resp files
        delimiter = ' ';
        startRow = 2;
        formatSpec = '%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);
        resp = table(dataArray{1:end-1}, 'VariableNames', {'Time_tics','RESP'});
        clearvars delimiter startRow formatSpec fileID dataArray ans;

        resp = table2array(resp);
        N = length(resp(:,2));
        NV = 0:N-1;
        t = NV/50; 
        file_length = t(end)/60;
        
        
        if file_length > 3
            file_type = "REST";
        else
            file_type = "BOLD";
        end
    
        % Apply smoothing filter
        windowWidth = 40;
        coeff = ones(round(windowWidth),1)/windowWidth;
        avgR = filter(coeff, 1, resp(:,2));            
        
        [pks, peaklocs] = findpeaks(avgR, t', 'MinPeakDistance', 2);
        
        if isempty(peaklocs) 
            period2R = 0;
            breaths = 0;
          
        else 
            
            period = mean(diff(peaklocs));
            % One method of calculating respiration
            period2R = num2cell(60/period);
%           first_pk = peaklocs(1);
%           last_pk = peaklocs(end);

            % A second method for calculating respiration
            breaths = length(pks)/file_length;
        end

        
        %% Now Process Pulse Oximeter
        
        filenamePuls = strcat(file, '/', filesPuls(f).name);
        
        % Read pulse files
        delimiter = ' ';
        startRow = 2;
        formatSpec = '%f%f%[^\n\r]';
        fileID = fopen(filenamePuls,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);
        ecg = table(dataArray{1:end-1}, 'VariableNames', {'Time_tics','ECG3'});
        clearvars delimiter startRow formatSpec fileID dataArray ans;
    
        ECG = table2array(ecg(:,2));
        N = height(ecg(:,2));
        NV = 0:N-1;
        tPuls = (NV/200)';
        
        % Remove first 15 seconds
        ECG(1:3000) = [];
        tPuls(1:3000) = [];

        % Remove last 10 seconds
        Last = length(ECG) - 2000;
        ECG(Last:length(ECG)) = [];
        tPuls(Last:length(tPuls)) = [];
        
        scaling_factor = 0.01;
        sig=(ECG-2048)*scaling_factor;
        
        % Apply smoothing filter
        windowWidth = 40;
        coeff = ones(round(windowWidth),1)/windowWidth;
        sig_mV = filter(coeff, 1, sig);
        
        
        
        [pks, peaklocs] = findpeaks(sig_mV, tPuls, 'MinPeakDistance', .5, 'MinPeakHeight', 0);  

        if isempty(peaklocs)
            period2HR = 0;
            hr2 = 0;
            RMSSD = 0;
            hr = horzcat(name, file_type, file_length, period2HR, hr2, RMSSD, period2R, breaths);
            HR = vertcat(HR,hr);
            continue
        end
        
        % Remove first peak as it might be partially recorded
        peaklocs(1) = [];
        pks(1) = [];

        rr = diff(peaklocs);
        dif = diff(rr);
        RMSSD = sqrt(mean(dif.^2)) * 1000;

        period = mean(diff(peaklocs));
        % One method of calculating heart rate
        period2HR = num2cell(60/period);
        % Another method for calculating heart rate
        hr2 = num2cell(length(pks)/(tPuls(end)/60));
          
        % Combine variables into table
        hr = horzcat(name, file_type, file_length, period2HR, hr2, RMSSD, period2R, breaths);
    
        if count == 1 
            HR = hr;
        else
            HR = vertcat(HR,hr);
        end
        
        fprintf('Processing Scan: %s \n', char(name));
        
        count = count + 1;
    end
    
end

   HR = array2table(HR);
   HR.Properties.VariableNames = {'ScanID' 'ScanType' 'ScanLength' 'HR' 'HR2' 'RMSSD' 'Respiration' 'Respiration2'};
%    HR.ScanLength = str2double(HR.ScanLength);
%    HR.HR = str2double(HR.HR);
%    HR.HR2 = str2double(HR.HR2);
%    HR.Respiration = str2double(HR.Respiration);
%    HR.Respiration2 = str2double(HR.Respiration2);
   writetable(HR, strcat(output,'PulsOxRMSSD_CutFinal_new.csv'), 'Delimiter',',');
