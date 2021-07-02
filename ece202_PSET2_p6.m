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
acc = zeros(1,3);
gyr = zeros(1,3);
mag = zeros(1,3);
ori = zeros(1,3);

acc_prev = zeros(1,3);
gyr_prev = zeros(1,3);
mag_prev = zeros(1,3);
ori_prev = zeros(1,3);

ori_data = zeros(1,3);
%lin_acc = zeros(1,3);
%grv = zeros(1,3);

yaw_pitch_roll_cf = zeros(1,3);
yaw_pitch_roll_ILKF = zeros(1,3);
data = zeros(1,1);

fs = 50; %Sample Rate in Hz

fuse_CF = complementaryFilter('SampleRate',fs,'HasMagnetometer',false);

GyroscopeNoiseMPU9250 = 3.0462e-06; % GyroscopeNoise (variance value) in units of rad/s
AccelerometerNoiseMPU9250 = 0.0061; % AccelerometerNoise(variance value)in units of m/s^2
viewer = HelperOrientationViewer('Title',{'AHRS Filter'});
fuse_ILKF = ahrsfilter('SampleRate',fs, 'GyroscopeNoise',GyroscopeNoiseMPU9250,'AccelerometerNoise',AccelerometerNoiseMPU9250);

k = 1;
stopTimer = 20;
tic;
while (toc < stopTimer)

    [msg,~] = fread(u,25);
    
    msgCell = strsplit(char(msg)',',');
    data(k,1:size(msgCell,2)) = str2double(msgCell);
    
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
        acc = acc_prev;
    end
    if(isnan(gyr))
        gyr = gyr_prev;
    end
    if(isnan(mag))
        mag = mag_prev;
    end
    if(isnan(ori))
        ori = ori_prev;
    end 
    acc_prev = acc;
    gyr_prev = gyr;
    mag_prev = mag;
    ori_prev = ori;

    ori_data(k,:) = ori;
    %{
    if(isnan(lin_acc))
        lin_acc = lin_acc;
    end
    if(isnan(grv))
        grv = grv;
    end
    %}
    
    fprintf('Timestamp:%f- ', time_stamp);
    fprintf(' Acc:[%f %f %f], Gyr:[%f %f %f], Mag:[%f %f %f], Ori:[%f %f %f], Lin.acc:[%f %f %f], Grav.:[%f %f %f]', acc(:),gyr(:),mag(:),ori(:),lin_acc(:),grv);
    fprintf('\n');
    
    %q_cf = fuse_CF(acc,gyr);
    %q_ILKF = fuse_ILKF(acc,gyr,mag);
    
    yaw_pitch_roll_cf(k,:) = eulerd(fuse_CF(acc,gyr),'XYZ','frame');
    yaw_pitch_roll_ILKF(k,:) = eulerd(fuse_ILKF(acc,gyr,mag),'XYZ', 'frame');
    
   % fprintf('cf:[%f %f %f], ILKF:[%f %f %f]',yaw_pitch_roll_cf(:), yaw_pitch_roll_ILKF(:));
   % fprintf('\n');
   
    k=k+1;
    %plot(toc,yaw_pitch_roll_cf(1), yaw_pitch_roll_ILKF(1), ori(1));
    
end


% Close all instruments
fclose(instrfindall);
