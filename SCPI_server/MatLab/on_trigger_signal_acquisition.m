%% Define Red Pitaya as TCP/IP object
clear all
close all
clc
IP = '192.168.1.106';                 % Input IP of your Red Pitaya...
port = 5000;
RP = tcpclient(IP, port);               % Define Red Pitaya as TCP/IP object (connection to remote server)
RP.InputBufferSize = 16384*32;        % Buffer sizes are calculated automatically with the new syntax

%% Open connection with your Red Pitaya

RP.ByteOrder = "big-endian";
configureTerminator(RP, 'CR/LF');

flush(RP, "input");
flush(RP, "output");

% Set decimation vale (sampling rate) in respect to you
% acquired signal frequency

writeline(RP,'ACQ:RST');
writeline(RP,'ACQ:DEC 1');
writeline(RP,'ACQ:TRIG:LEV 0');

% there is an option to select coupling when using SIGNALlab 250-12
% writeline(RP,'ACQ:SOUR1:COUP AC');    % enables AC coupling on channel 1

% by default LOW level gain is selected
% writeline(RP,'ACQ:SOUR1:GAIN LV');    % user can switch gain using this command


% Set trigger delay to 0 samples
% 0 samples delay set trigger to the center of the buffer
% Signal on your graph will have trigger in the center (symmetrical)
% Samples from left to the center are samples before trigger
% Samples from center to the right are samples after trigger

writeline(RP,'ACQ:TRIG:DLY 0');

%% Start & Trigg
% Trigger source setting must be after ACQ:START
% Set trigger to source 1 positive edge

writeline(RP,'ACQ:START');

% After acquisition is started some time delay is needed in order to acquire fresh samples in the buffer
% Here we have used time delay of one second, but you can calculate the exact value by taking into account buffer
% length and sampling rate

writeline(RP,'ACQ:TRIG CH1_PE');

% Wait for trigger
% Until trigger is true wait with acquiring
% Be aware of the while loop if trigger is not achieved
% Ctrl+C will stop code executing in MATLAB

while 1
        trig_rsp = writeread(RP,'ACQ:TRIG:STAT?')

        if strcmp('TD', trig_rsp(1:2))      % Read only TD

            break

        end
    end


% Read data from buffer
signal_str   = writeread(RP,'ACQ:SOUR1:DATA?');
signal_str_2 = writeread(RP,'ACQ:SOUR2:DATA?');

% Convert values to numbers.
% First character in the string is “{“
% and the last 3 are 2 empty spaces and a “}”.

signal_num   = str2num(signal_str  (1, 2:length(signal_str)-3));
signal_num_2 = str2num(signal_str_2(1, 2:length(signal_str_2)-3));

plot(signal_num)
hold on
plot(signal_num_2,'r')
grid on
ylabel('Voltage / V')
xlabel('samples')

clear RP;