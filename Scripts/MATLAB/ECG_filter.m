% This script loops through raw ECG data for each subject, runs a bandpass filter
% over each raw signal, and outputs the filtered signal into a new directory

directory = '/Volumes/data-CC1486-Psychiatry/Physio_MM';
output = '/Volumes/data-CC1486-Psychiatry/';
folders = dir(directory);

Fs = 400;
highCutOff = 50;
lowCutOff = 4;

[B,A] = butter(3, [lowCutOff highCutOff]/Fs, 'bandpass');

for i = 1:length(folders)
    
    file = strcat(directory, '/', folders(i).name);
    filepattern = fullfile(file,'*ECG3.log') ;
    files = dir(filepattern);
    
    if isempty(files)
        continue
    end
    
    folderName = folders(i).name;
    newFolder = strcat(output, 'Filtered_Physio_MM/', folderName);
    if (exist(newFolder, 'dir') == 0)
        mkdir(newFolder);
    end
    
    for f = 1:numel(files)
        
        
        filename = strcat(file, '/', files(f).name);
        len = strlength(files(f).name);
        name = char(extractBetween(files(f).name, 1, len - 4));
        
        newFile = strcat(newFolder, '/',name, '.csv');
        
        if (exist(newFile, 'file') ~= 0)
            continue
        end
        
        delimiter = ' ';
        startRow = 2;
        formatSpec = '%f%f%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        fclose(fileID);
        ecg = table(dataArray{1:end-1}, 'VariableNames', {'Time_tics','ECG3'});
        clearvars delimiter startRow formatSpec fileID dataArray ans;
        
        ECG = table2array(ecg(:,2));
        N = height(ecg(:,2));
        NV = 0:N-1;
        t = (NV/400)'; 
        
        scaling_factor = 0.01;
        sig=(ECG-2048)*scaling_factor;
        
        % Apply both Buttworth filter
        sig_mV = filter(B, A, sig);
        signal = horzcat(t, sig_mV);
        
        
        fprintf(strcat("Filtering subject: ", folderName, '\n'));
        fprintf(strcat("File: ", name, '\n'));
        
        csvwrite(newFile, signal);
      
        
    end
    
end
