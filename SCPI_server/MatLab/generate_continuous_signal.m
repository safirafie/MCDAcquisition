%% Define Red Pitaya as TCP/IP object

IP= '169.254.57.89';           % Input IP of your Red Pitaya...
port = 5000;
tcpipObj=tcpip(IP, port);

%% Open connection with your Red Pitaya

fopen(tcpipObj);
% configureTerminator(tcpipObj,"CR/LF")
tcpipObj.Terminator = 'CR/LF';

fprintf(tcpipObj,'GEN:RST');               % Reset generator

fprintf(tcpipObj,'SOUR1:FUNC square');       % Set function of output signal
                                           % {sine, square, triangle, sawu,sawd, pwm}
fprintf(tcpipObj,'SOUR1:FREQ:FIX 500');   % Set frequency of output signal
fprintf(tcpipObj,'SOUR1:VOLT 0.8');          % Set amplitude of output signal

fprintf(tcpipObj,'OUTPUT1:STATE ON');      % Set output to ON
fprintf(tcpipObj,'SOUR1:TRIG:INT');        % Generate trigger

%% Close connection with Red Pitaya

fclose(tcpipObj);