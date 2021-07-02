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
lin_acc = zeros(1,3);
grv = zeros(1,3);

acc_prev = zeros(1,3);
gyr_prev = zeros(1,3);
mag_prev = zeros(1,3);
ori_prev = zeros(1,3);
lin_acc_prev = zeros(1,3);
grv_prev = zeros(1,3);
 
% Preallocating
msgMat = zeros(99,3);
k = 1;
 
while k < 200
 
    [msg,~] = fread(u,10);
   
    %msgCell = strsplit(char(msg)',',');
    n_z = string(char(msg)');
    msg_c = char(msg)';
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
    if(isnan(lin_acc))
        lin_acc = lin_acc_prev;
    end
    if(isnan(grv))
        grv = grv_prev;
    end
    
    acc_prev = acc;
    gyr_prev = gyr;
    mag_prev = mag;
    ori_prev = ori;
    lin_acc_prev = lin_acc;
    grv_prev = grv;
    
    fprintf('Timestamp:%f- ', time_stamp);
    fprintf(' Acc:[%f %f %f], Gyr:[%f %f %f], Mag:[%f %f %f], Ori:[%f %f %f], Lin.acc:[%f %f %f], Grav.:[%f %f %f]', acc(:),gyr(:),mag(:),ori(:),lin_acc(:),grv);
    fprintf('\n')
 
    %fprintf(msg_c');
    %fprintf('\n');
 
    k = k + 1;
 
end
% Close all instruments
fclose(instrfindall);

