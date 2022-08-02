% The code is written in MATLAB. In the code we use SCPI commands and TCP/IP communication. Copy code to MATLAB editor and press run.

%% Define Red Pitaya as TCP/IP object
clear
close all
clc
IP= '192.168.1.106';                % Input IP of your Red Pitaya...
port = 5000;
tcpipObj = tcpclient(IP, port);
tcpipObj.InputBufferSize = 16384*32;

%% Open connection with your Red Pitaya

fopen(tcpipObj);
configureTerminator(tcpipObj,"CR/LF")
%tcpipObj.Terminator = 'CR/LF';

flushinput(tcpipObj);
flushoutput(tcpipObj);

% Set decimation vale (sampling rate) in respect to you
% acquired signal frequency

fprintf(tcpipObj,'ACQ:RST');
fprintf(tcpipObj,'ACQ:DEC 8');
fprintf(tcpipObj,'ACQ:TRIG:LEV 0');


% Set trigger delay to 0 samples
% 0 samples delay set trigger to center of the buffer
% Signal on your graph will have trigger in the center (symmetrical)
% Samples from left to the center are samples before trigger
% Samples from center to the right are samples after trigger

fprintf(tcpipObj,'ACQ:TRIG:DLY 0');

% for SIGNALlab device there is a possiblity to set trigger threshold
% fprintf(tcpipObj,'ACQ:TRIG:EXT:LEV 1')


%% Start & Trigg
% Trigger source setting must be after ACQ:START
% Set trigger to source 1 positive edge

fprintf(tcpipObj,'ACQ:START');
% After acquisition is started some time delay is needed in order to acquire fresh samples in to buffer
% Here we have used time delay of one second but you can calculate exact value taking in to account buffer
% length and smaling rate
pause(1)

fprintf(tcpipObj,'ACQ:TRIG EXT_PE');
% Wait for trigger
% Until trigger is true wait with acquiring
% Be aware of while loop if trigger is not achieved
% Ctrl+C will stop code executing in MATLAB

while 1
    trig_rsp=query(tcpipObj,'ACQ:TRIG:STAT?');

    if strcmp('TD',trig_rsp(1:2))  % Read only TD

    break

    end
end


% Read data from buffer
signal_str=query(tcpipObj,'ACQ:SOUR1:DATA?');
signal_str_2=query(tcpipObj,'ACQ:SOUR2:DATA?');

% Convert values to numbers.% First character in string is “{“
% and 2 latest are empty spaces and last is “}”.

signal_num=str2num(signal_str(1,2:length(signal_str)-3));
signal_num_2=str2num(signal_str_2(1,2:length(signal_str_2)-3));

plot(signal_num)
hold on
plot(signal_num_2,'r')
grid on
ylabel('Voltage / V')
xlabel('samples')

fclose(tcpipObj);