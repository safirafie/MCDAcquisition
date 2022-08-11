%% Description
%{
 Description:
 -----------
 Generate.

 Parameters (inputs): (Type)
 -----------

 Returns (outputs): (Type)
 -----------
 
 License:
 -------
 MIT License
 Copyright (c) 2022 by Safi Rafie-Zinedine
 A part of MCDAcquisition package: https://github.com/safirafie/MCDAcquisition

 Tested on:
 ------------------
 MatLab 2022a
%}

%% Prepare workspace
clear
close all;
clc;
tic;

%% Define Red Pitaya as TCP/IP object
IP= '192.168.1.106';           % Input IP of your Red Pitaya...
port = 5000;
tcpipObj=tcpclient(IP, port);
flushinput(tcpipObj);
flushoutput(tcpipObj);


%% Open connection with your Red Pitaya
fopen(tcpipObj);
configureTerminator(tcpipObj,"CR/LF")
% generator reset
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
%fclose(tcpipObj);