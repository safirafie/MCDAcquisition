%% Prepare workspace
clear
close all;
clc;
tic;

%% Control
plot_data = 0;
save_data = 0;

n_sample = 16383;  % This is the maximum number of sample 16383
n_bin = 20;
n_seq = 20;


%% Define Red Pitaya as TCP/IP object
IP= '192.168.1.106';           % Input IP of your Red Pitaya...
port = 5000;
tcpipObj=tcpclient(IP, port);
flushinput(tcpipObj);
flushoutput(tcpipObj);

%% Open connection with your Red Pitaya
fopen(tcpipObj);
configureTerminator(tcpipObj,"CR/LF")

counts = cell(size(1, n_seq));
bins = zeros(1,n_bin);
for seq = 1:n_seq
    %% Generators
    % Reset generators
    fprintf(tcpipObj,'GEN:RST');
    % generator channel 1 "pulses / couts"
    fprintf(tcpipObj,'SOUR1:FUNC DC');
    fprintf(tcpipObj,'SOUR1:FREQ:FIX 4000000');    % Set frequency of output signal
    fprintf(tcpipObj,'SOUR1:VOLT 0.8');           % Set amplitude of output signal
    fprintf(tcpipObj,'SOUR1:BURS:STAT BURST');  % Set burst mode to ON
    fprintf(tcpipObj,'SOUR1:BURS:NCYC 1');      % Set 1 pulses of sine wave
    fprintf(tcpipObj,'SOUR1:BURS:NOR 10000');   % Infinity number of sine wave pulses
    fprintf(tcpipObj,'SOUR1:BURS:INT:PER 100'); % Set time of burst period in microseconds = 5 * 1/Frequency * 1000000
    fprintf(tcpipObj,'OUTPUT1:STATE ON');
    fprintf(tcpipObj,'SOUR1:TRIG:INT');
    % Generator channel 2 "trigger"
    fprintf(tcpipObj,'SOUR2:FUNC SQUARE');
    fprintf(tcpipObj,'SOUR2:FREQ:FIX 250');
    fprintf(tcpipObj,'SOUR2:VOLT 0.8');
    fprintf(tcpipObj,'OUTPUT2:STATE ON');
    fprintf(tcpipObj,'SOUR2:TRIG:INT');

    %% Oscilloscope
    % Set decimation vale (sampling rate)
    fprintf(tcpipObj,'ACQ:RST');
    fprintf(tcpipObj,'ACQ:DEC 16');
    fprintf(tcpipObj,'ACQ:START');
    % Trigger settings
    fprintf(tcpipObj,'ACQ:TRIG:LEV 500 mV');
    fprintf(tcpipObj,'ACQ:TRIG:DLY 8150');
    fprintf(tcpipObj,'ACQ:TRIG CH2_PE');

    %% Read data from buffer
    signal_str = query(tcpipObj,'ACQ:SOUR1:DATA?');
    signal_str_2 = query(tcpipObj,'ACQ:SOUR2:DATA?');
    signal_num = str2num(signal_str(1,2:length(signal_str)-3));
    signal_num_2 = str2num(signal_str_2(1,2:length(signal_str_2)-3));
    
    % Plot
    if plot_data
        t = linspace(0,2e-3,n_sample+1);
        hold on
        plot(t,signal_num)
        hold on
        plot(t,signal_num_2,'r')
        grid on
        ylabel('Voltage (V)')
        xlabel('Time (s)')
    end



    [peaks, locs] = findpeaks(signal_num,'MinPeakProminence',0.3);
    counts{seq} = locs;
%     toc
end

% Distribute the counts in bins
for i = 1:n_seq
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