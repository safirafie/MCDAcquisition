% % Stream
% stream_command = 'cls && cd rpsa_client_104\ && ptime rpsa_client.exe -s -h 169.254.57.89 -p 8900 -f wav -d ./output/ -l 15000 -m volt && cd ./output && RENAME *.wav seq1.wav && del *.log *.lost';
% system(stream_command);

n_repeat = 1;

%% Stream sample from Red Pitaya
% Stream
for i=1:n_repeat
    stream_command = sprintf('cls && cd rpsa_client_104/output && del *.wav && cd .. && ptime rpsa_client.exe -s -h 169.254.57.89 -p 8900 -f wav -d ./output/ -l %i -m volt && cd output && RENAME *.wav repeat_%i.wav && del *.log *.lost',n_sample,i);
    system(stream_command);
end


