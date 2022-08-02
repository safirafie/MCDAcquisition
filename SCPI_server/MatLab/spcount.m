 % instrreset
% lc = visa('ni','TCPIP0::130.235.188.64::inst0::INSTR');
% fopen(lc);

% fprintf(lc,'ARM;WAIT');
% fwrite(lc,"vbs? 'return=app.measure.p1.out.result.value'");
% a = fscanf(lc);
% counts_on(vec_pos) = str2num(a);

tic;
instrreset;
% close all;
clear all;
clc;
addpath('C:\matlab_programs\Common')
addpath('C:\matlab_programs\Common\LeCroyMethods')

save_data = 0;
n_avg = 10;
n_samp =20e3;
n_seg = 500;%20
n_bin = 10;
n_rep = 1;

for k = 1:n_rep
counts = cell(size(1, n_seg));
bins = zeros(1,n_bin);
tic

for n = 1:n_avg
    n
    [t, y_cell, wave_info] = Read_LeCroy('channels', {'C2'}, 'readOnly', false, 'nbrSeg', n_seg, 'sampSeg', n_samp);
    toc
    y = cell2mat(y_cell{1});
%     plot(t,y(:,19))
    for seg = 1:n_seg
        
        [peaks, locs] = findpeaks(y(:,seg),'MinPeakProminence',0.3);
        counts{seg} = locs;
    end
    
    toc
       
    for i = 1:n_seg
        for j = 1:length(counts{i})
            bi = ceil(counts{i}(j)/(n_samp/n_bin)); % bin index
            bins(bi) = bins(bi)+1;
        end
        
    end
    toc
    clearvars -except bins n_avg n_samp n_seg n_bin t save_data
    instrreset;
end
bins = bins; %/n_avg;
toc
% [t, ref_cell, wave_info] = Read_LeCroy('channels', {'C1'}, 'readOnly', false, 'nbrSeg', 1, 'sampSeg', sampSeg);
% y_ref = cell2mat(ref_cell{1});
counts = sum(bins)

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
end
toc;

figure
% plot(t,cell2mat(C{2}))
plot(bins, 'o')


load handel
sound(y,Fs)