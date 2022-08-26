cls
ptime rpsa_client.exe -s -h 169.254.57.89 -p 8900 -f wav -d ./output/ -l 15000 -m volt
cd ./output
RENAME *.wav seq1.wav
del *.log *.lost


REM pause