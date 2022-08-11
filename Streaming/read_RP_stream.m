function [tot_stream1,tot_stream2,Fs] = read_RP_stream(readout_time)

%% while writing
UOT_image = [];


%% Hardocded variables
%TCPIP address to RP
address = '169.254.240.31';

%Which port that is used by the stream
port = 8900;

%Length of each packet in stream,
ch_sig_length = 16384;

header_length = 30;

%tcp matlab object
tcp = tcpclient(address,port,"ConnectTimeout",2,"EnableTransferDelay",true);

%sample speed, somehwat ambiguous, and differs a bit when measured but it
%looks like it is the 125 MS/s decimated by 13.
Fs = 125e6/13;

%volts per digital level, max input to RP low voltage (LV) is +- 1V
VperDig1 = 3.0934e-5;

%volts per digital level, max input to RP high voltage (LV) is +- 20V
VperDig2 = 3.0934e-5*20;

% period of the stream readout
readout_period = 150e-3; % s

% number of cycles of reading the stream, adding one to auld lang syne
readout_cycles = ceil(readout_time/readout_period)-1;

%


ch1_cell = cell(readout_cycles+5,1);
ch2_cell = ch1_cell;

% flush(tcp,'input')
for i = 1:10
    tic
    while toc <50e-3
    end
    
   flush(tcp,'input')
end
tt = tic;
t0 = toc(tt);
i = 1;
while true
%     disp(toc(tt) - t0-(i-1)*readout_period) 
    if (toc(tt) - t0) > readout_time
        break
    end
    while (toc(tt)-t0) <i*readout_period
    end
    ADC = read(tcp,tcp.NumBytesAvailable,'int16');
%     flush(tcp)
    %     disp(num2str(toc(tt)-t1))
    [ch1,ch2,lost_packages] = rp_tcp2ch_16bit(ADC);
    if lost_packages
        disp('package lost')
    end
    I = find(ch1>16384/2,1,"first");
    ch1_cell{i} = double(ch1)*VperDig1;
    ch2_cell{i} = double(ch2)*VperDig2;

    i = i+1;
end

clear tcp

tot_stream1 = cell2mat(ch1_cell(1:i));
tot_stream2 = cell2mat(ch2_cell(1:i));

clear ch*;
end
