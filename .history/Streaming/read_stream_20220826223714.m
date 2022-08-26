%% Description
%{
 Read the stream.

 Inputs: 
 Outputs: 
 --------
 
 License:
 --------
 MIT License
 Copyright (c) 2022 by Safi Rafie-Zinedine
 A part of MCDAcquisition package: https://github.com/safirafie/MCDAcquisition
 
 Tested on: MatLab 2022a 
%}

%% Prepare workspace
clear
close all;
clc;
tic;

%% Read file
datafile = 'data_file.bin';
fileID = fopen(datafile);
data_ch1_ch2 = fread(fileID);
fclose(fileID);

%% Control
plot_data = 1;
save_data = 0;

cycle_duration = 4e-3;
n_sample = length(data_ch1_ch2);
n_bin = 20;
counts = cell(size(1, 1));
bins = zeros(1,n_bin);
CH1 = data_ch1_ch2(:,1);
% CH2 = data_ch1_ch2(:,2);
% Plot
if plot_data
    t = linspace(0,cycle_duration,n_sample);
    hold on
    plot(t,CH1)
    hold on
%     plot(t,CH2,'r')
    grid on
    ylabel('Voltage (V)')
    xlabel('Time (s)')
end



[peaks, locs] = findpeaks(CH1,'MinPeakProminence',0.3);
counts{1} = locs;

% Distribute the counts in bins
for i = 1:1
        for j = 1:length(counts{i})
            bi = ceil(counts{i}(j)/(n_sample/n_bin));
            bins(bi) = bins(bi)+1;
        end        
end
total_counts = sum(bins)

% Plot
figure
plot(bins, 'o')


% Save data
if save_data
    close all
    
    %% Save File
    dir_name = '_sp_Flou';       % Name for parent directory
    file_name = '';           % Name for inidividual files
        dataroot = 'G:\Echo\Experimental Data\Micro_Cavity\MCT_instrument_control\experimental_data\'    
    timestamp = now;
    year      = datestr(timestamp,'yyyy');
    month     = datestr(timestamp,'mm');
    day       = datestr(timestamp,'dd');
    hms      = datestr(timestamp,'HHMMSS');
    oldpwd   = cd;                                  % Save current directory to come back to it after files are saved
    
    cd(dataroot);                                   % Change to data directory
    
    %%% Create/change folder
    % Change to 'year' folder
    if ~exist(year,'dir')
        mkdir(year);
    end
    cd(year);
    
    % Change to 'month' folder
    monthNs = { ...
        '01_january'; ...
        '02_february'; ...
        '03_march'; ...
        '04_april'; ...
        '05_may'; ...
        '06_june'; ...
        '07_july'; ...
        '08_august'; ...
        '09_september'; ...
        '10_october'; ...
        '11_november'; ...
        '12_december'};
    
    monthN = char(monthNs(str2double(month)));
    
    if ~exist(monthN,'dir')
        mkdir(monthN);
    end
    cd(monthN);
    
    % Change to 'day_absorptionspectra' folder
    dayname = strcat(day, dir_name);
    if ~exist(dayname,'dir')
        mkdir(dayname);
    end
    cd(dayname);
    
    %%% Filename and save
    filename = sprintf('%s.mat',hms);
    save(filename);
    cd(oldpwd)
    disp(['Data saved: ', filename])
    pause(1);
    tag=hms;
    clipboard('copy',tag);
    fprintf('Copied ''%s'' to clipboard.\n',tag);
end

toc