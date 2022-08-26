%% Description
%{
 Stream and analyse.

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


%% Control
plot_first_seq = 0;
fit_bins = 0;
save_data = 0;

n_sample = 15000000;
n_repeat = 1;
n_bin = 20;
trigger_level = 0.6;
detection_time = 2e-3;


%% Stream sample from Red Pitaya
% Stream {decemation is 50, resolution: 16 bit, mode: volt, Protocol: TCP}
for i=1:n_repeat
    stream_command = sprintf('cls && cd rpsa_client_104/output && del *.wav && cd .. && ptime rpsa_client.exe -s -h 169.254.57.89 -p 8900 -f wav -d ./output/ -l %i -m volt && cd output && RENAME *.wav repeat_%i.wav && del *.log *.lost',n_sample,i);
    system(stream_command);
end

%% Read file bin or wav file
% WAV
datafile_wav = '.\rpsa_client_104\output\repeat_1.wav';
[data_ch1_ch2,Fs] = audioread(datafile_wav);
disp(['Time after read wav file: ', num2str(toc)]);


%% Trigger
CH1 = data_ch1_ch2(:,1);
CH2 = data_ch1_ch2(:,2);
CH2 = CH2 > trigger_level;
start_cut = find(CH2==0, 1, 'first');
end_cut = find(CH2==0, 1, 'last');
CH2 = CH2(start_cut:end_cut);
CH1 = CH1(start_cut:end_cut);
n_sample_detection = detection_time*Fs;
n_seq = round(length(CH2(CH2==1))/n_sample_detection);
t_total_detection = n_seq * detection_time;
CH1_cell = cell(size(1, n_seq));
first_start_seq = find(CH2==1, 1, 'first');
% Slice CH1 into sequences
for i=1:n_seq
    start_cut_seq = find(CH2==1, 1, 'first');
    CH2 = CH2(start_cut_seq:end);
    CH1 = CH1(start_cut_seq:end);
    end_cut_seq = find(CH2==0, 1, 'first');
    CH1_cell{i} = CH1(1:end_cut_seq-1);
    CH2 = CH2(end_cut_seq:end);
    CH1 = CH1(end_cut_seq:end);
end
disp(['Time after trigger: ', num2str(toc)]);


%% Plot detection signal
if plot_first_seq
    t = linspace(0,detection_time,length(CH1_cell{1}));
    hold on
    plot(t,CH1_cell{1})
    hold on
    plot(t,data_ch1_ch2(start_cut+first_start_seq:start_cut+first_start_seq+length(CH1_cell{1})-1,2),'r')
    grid on
    ylabel('Voltage (V)')
    xlabel('Time (s)')
end

%% Find counts
counts = cell(size(1, n_seq));
for seq = 1:n_seq
    [peaks, locs] = findpeaks(CH1_cell{i},'MinPeakProminence',0.01);
    counts{seq} = locs;
end

% Distribute the counts in bins
bins = zeros(1,n_bin+1);
for i = 1:n_seq
    for j = 1:length(counts{i})
        bi = round(counts{i}(j)/(n_sample_detection/n_bin))+1;
        bins(bi) = bins(bi)+1;
    end
end

% Results
total_counts = sum(bins);
total_dark_counts = 20*t_total_detection;
fprintf('\n--------------------------------------------------------------');
fprintf('\n         The total counts is: %i',total_counts);
fprintf('\n--------------------------------------------------------------');
fprintf('\n         The total dark counts: %i',total_dark_counts);
fprintf('\n--------------------------------------------------------------');

%% Plot counts
figure
plot(bins, 'o')
grid on
ylabel('Counts')
xlabel('Bins')
xlim([0 n_bin+1])

if fit_bins
    % Fit: 'lifetime'.
    [xData, yData] = prepareCurveData( [], bins );

    % Set up fittype and options.
    ft = fittype( 'exp2' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [0 0 0 0];

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    % Plot fit with data.
    hold on
    h = plot( fitresult, xData, yData );
    legend( h, 'bins', 'lifetime', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    ylabel( 'bins', 'Interpreter', 'none' );

    b = fitresult.b;
    d = fitresult.d;
    lifetime_1 = 1/b;
    lifetime_2 = 1/d;

    fprintf('\n         The lifetime 1: %d,   The lifetime 2: %d',lifetime_1,lifetime_2);
    fprintf('\n--------------------------------------------------------------');
end


%% Save data
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
fprintf('\n');
toc

%% number of count that is generated
pulse_frq = 4e3;
total_count_generated = n_seq*detection_time/(1/pulse_frq)
% load handel
% sound(y,Fs)
