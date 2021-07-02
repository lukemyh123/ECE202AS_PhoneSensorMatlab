%% Android Sensors 2 Matlab
%
%
 
close all
clear all
clc
 
% Deleting   all instruments
delete(instrfindall);
 
% Set up
phoneIP = '192.168.4.121';
port = 5555;
 
u = udp(phoneIP , port - 1 , 'LocalPort' , port , 'InputBufferSize' , 1024);
fopen(u);
 
time_stamp = 0;
acc = [0,0,0];
gyr = [0,0,0];
mag = [0,0,0];
ori = [0,0,0];
lin_acc = [0,0,0];
grv = [0,0,0];
 
% Preallocating
msgMat = zeros(99,3);

 
fs = 50; %Sample Rate in Hz
 
% GyroscopeNoise and AccelerometerNoise is determined from datasheet.
GyroscopeNoiseMPU9250 = 3.0462e-06; % GyroscopeNoise (variance value) in units of rad/s
AccelerometerNoiseMPU9250 = 0.0061; % AccelerometerNoise(variance value)in units of m/s^2
viewer = HelperOrientationViewer('Title',{'AHRS Filter'});
FUSE = ahrsfilter('SampleRate',fs, 'GyroscopeNoise',GyroscopeNoiseMPU9250,'AccelerometerNoise',AccelerometerNoiseMPU9250);
stopTimer = 100000;
 
tic;
while (toc < stopTimer)
 
    [msg,~] = fread(u,10);
   
    %msgCell = strsplit(char(msg)',',');
    n_z = string(char(msg)');
    msg_c = char(msg)';
    %problem_4
    time_stamp = str2double(msg_c(1:strfind(n_z,", 3, ")-1));
    acc = str2double(strsplit(string(msg_c(strfind(n_z,", 3, ")+5:strfind(n_z,", 4, ")-1)),","));
    gyr = str2double(strsplit(string(msg_c(strfind(n_z,", 4, ")+5:strfind(n_z,", 5, ")-1)),","));
    mag = str2double(strsplit(string(msg_c(strfind(n_z,", 5, ")+5:strfind(n_z,", 81, ")-1)),","));
    ori = str2double(strsplit(string(msg_c(strfind(n_z,", 81, ")+5:strfind(n_z,", 82, ")-1)),","));
    lin_acc = str2double(strsplit(string(msg_c(strfind(n_z,", 82, ")+5:strfind(n_z,", 83, ")-1)),","));
    grv = str2double(strsplit(string(msg_c(strfind(n_z,", 83, ")+5:end)),","));
    
    if(isnan(acc))
        acc = [0 0 0];
    end
    if(isnan(gyr))
        gyr = [0 0 0];
    end
    if(isnan(mag))
        mag = [0 0 0];
    end
    if(isnan(ori))
        ori = [0 0 0];
    end
    if(isnan(lin_acc))
        lin_acc = [0 0 0];
    end
    if(isnan(grv))
        grv = [0 0 0];
    end
    
    rotators = FUSE(acc,gyr,mag);
    for j = numel(rotators)
        viewer(rotators(j));
    end
    
    fprintf('Timestamp:%f- ', time_stamp);
    fprintf(' Acc:[%f %f %f], Gyr:[%f %f %f], Mag:[%f %f %f], Ori:[%f %f %f], Lin.acc:[%f %f %f], Grav.:[%f %f %f]', acc(:),gyr(:),mag(:),ori(:),lin_acc(:),grv);
    fprintf('\n')
   
    %fprintf(msg_c');
    %fprintf('\n');
    
    %problem_5
    
end
% Close all instruments
fclose(instrfindall);

