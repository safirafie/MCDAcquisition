clear
%% Define Red Pitaya as TCP/IP object

IP= '192.168.1.106';           % Input IP of your Red Pitaya...
port = 5000;
tcpipObj=tcpclient(IP, port);
flushinput(tcpipObj);
flushoutput(tcpipObj);

%% Open connection with your Red Pitaya

fopen(tcpipObj);
configureTerminator(tcpipObj,"CR/LF")
%tcpipObj.Terminator = 'CR/LF';




%%%%%%%%%%%% Generators
%% Calcualte arbitrary waveform with 16384 samples
% Values of arbitrary waveform must be in range from -1 to 1.
N=16383;
% t=0:(2*pi)/N:2*pi;
% x=sin(t)+1/3*sin(3*t);
% plot(t,x)
% grid on

%% Convert waveforms to string with 5 decimal places accuracy
% waveform_ch_1_0 =num2str(x,'%1.5f,');
%waveform_ch_2_0 =num2str(y,'%1.5f,');

% latest are empty spaces  “,”.
% waveform_ch_1 =waveform_ch_1_0(1,1:length(waveform_ch_1_0)-3);
%waveform_ch_2 =waveform_ch_2_0(1,1:length(waveform_ch_2_0)-3);

%%




% Reset generator
fprintf(tcpipObj,'GEN:RST');   

fprintf(tcpipObj,'SOUR1:FUNC DC');
fprintf(tcpipObj,'SOUR1:FREQ:FIX 2000000');    % Set frequency of output signal
fprintf(tcpipObj,'SOUR1:VOLT 0.8');           % Set amplitude of output signal

fprintf(tcpipObj,'SOUR1:BURS:STAT BURST');  % Set burst mode to ON
fprintf(tcpipObj,'SOUR1:BURS:NCYC 1');      % Set 1 pulses of sine wave
fprintf(tcpipObj,'SOUR1:BURS:NOR 10000');   % Infinity number of sine wave pulses
fprintf(tcpipObj,'SOUR1:BURS:INT:PER 100');% Set time of burst period in microseconds = 5 * 1/Frequency * 1000000




% Set function of output signal {sine, square, triangle, sawu,sawd, pwm}
%fprintf(tcpipObj,'SOUR1:FUNC ARBITRARY');       
%fprintf(tcpipObj,['SOUR1:TRAC:DATA:DATA ' waveform_ch_1]);  % Send waveforms to Red Pitya
%fprintf(tcpipObj,'SOUR1:FUNC SINE');       
fprintf(tcpipObj,'SOUR2:FUNC SQUARE');       
% Set frequency of output signal                
%fprintf(tcpipObj,'SOUR1:FREQ:FIX 2000000'); 
fprintf(tcpipObj,'SOUR2:FREQ:FIX 250'); 
% Set amplitude of output signal
%fprintf(tcpipObj,'SOUR1:VOLT 0.6');          
fprintf(tcpipObj,'SOUR2:VOLT 0.8');          
% Set output to ON
fprintf(tcpipObj,'OUTPUT1:STATE ON');      
fprintf(tcpipObj,'OUTPUT2:STATE ON');      
% Generate trigger
fprintf(tcpipObj,'SOUR1:TRIG:INT');        
fprintf(tcpipObj,'SOUR2:TRIG:INT');        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Oscilloscope


% Set decimation vale (sampling rate) in respect to you
% acquired signal frequency

fprintf(tcpipObj,'ACQ:RST');
fprintf(tcpipObj,'ACQ:DEC 16');
fprintf(tcpipObj,'ACQ:TRIG:LEV 500 mV');


% Set trigger delay to 0 samples
% 0 samples delay set trigger to center of the buffer
% Signal on your graph will have trigger in the center (symmetrical)
% Samples from left to the center are samples before trigger
% Samples from center to the right are samples after trigger

fprintf(tcpipObj,'ACQ:TRIG:DLY 8150');

% for SIGNALlab device there is a possiblity to set trigger threshold
% fprintf(tcpipObj,'ACQ:TRIG:EXT:LEV 1')


%% Start & Trigg
% Trigger source setting must be after ACQ:START
% Set trigger to source 1 positive edge

fprintf(tcpipObj,'ACQ:START');
% After acquisition is started some time delay is needed in order to acquire fresh samples in to buffer
% Here we have used time delay of one second but you can calculate exact value taking in to account buffer
% length and smaling rate
% pause(1)
% <source> = {DISABLED, NOW, CH1_PE, CH1_NE, CH2_PE, CH2_NE, EXT_PE, EXT_NE, AWG_PE, AWG_NE}
fprintf(tcpipObj,'ACQ:TRIG CH2_PE');
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
t = linspace(0,2e-3,N+1);

plot(t,signal_num)
hold on
plot(t,signal_num_2,'r')
grid on
ylabel('Voltage / V')
xlabel('Time')

n_bin = 20;
n_seg = 1;
counts = cell(size(1, n_seg));
bins = zeros(1,n_bin);
for seg = 1:n_seg
[peaks, locs] = findpeaks(signal_num(),'MinPeakProminence',0.3);
counts{seg} = locs;
end
for i = 1:n_seg
        for j = 1:length(counts{i})
            bi = ceil(counts{i}(j)/(N/n_bin)); % bin index
            bins(bi) = bins(bi)+1;
        end        
end
bins = bins; %/n_avg;

% [t, ref_cell, wave_info] = Read_LeCroy('channels', {'C1'}, 'readOnly', false, 'nbrSeg', 1, 'sampSeg', sampSeg);
% y_ref = cell2mat(ref_cell{1});
counts = sum(bins)
figure
plot(bins, 'o')


fclose(tcpipObj);