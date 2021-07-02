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

data = zeros(1,1);

k = 1;
while k < 200
    [msg,~] = fread(u,10);
    msgCell = strsplit(char(msg)',',');
    data(k,1:size(msgCell,2)) = str2double(msgCell);
    
    n_z = string(char(msg)');
    msg_c = char(msg)';
    fprintf(msg_c');
    fprintf('\n');
 
    k = k + 1;
 
end
% Close all instruments
fclose(instrfindall);
