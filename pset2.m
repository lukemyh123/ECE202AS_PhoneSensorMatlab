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

fs = 50; %Sample Rate in Hz

fuse_CF = complementaryFilter('SampleRate',fs,'HasMagnetometer',false);

GyroscopeNoiseMPU9250 = 3.0462e-06; % GyroscopeNoise (variance value) in units of rad/s
AccelerometerNoiseMPU9250 = 0.0061; % AccelerometerNoise(variance value)in units of m/s^2
viewer = HelperOrientationViewer('Title',{'AHRS Filter'});
fuse_ILKF = ahrsfilter('SampleRate',fs, 'GyroscopeNoise',GyroscopeNoiseMPU9250,'AccelerometerNoise',AccelerometerNoiseMPU9250);

% Preallocating
k = 1;

stored = zeros(1,1);
time = 0;
acc = zeros(1,3);
gyro = zeros(1,3);
mag = zeros(1,3);
ori = zeros(1,3);
linacc = zeros(1,3);
grav = zeros(1,3);

rotators = zeros(1,3);
q = zeros(1,3);

while k < 500
    
    [msg,~] = fread(u,25);
    
    msgCell = strsplit(char(msg)',',');
    
    stored(k,1:size(msgCell,2)) = str2double(msgCell);
    
    time = stored(k,1);
    if(size(find(stored(k,:) == 3),2))
        index = find(stored(k,:) == 3);
        acc = stored(k,index + 1 : index + 3);
    else
        acc = acc;
    end
    if(size(find(stored(k,:) == 4),2))
        index = find(stored(k,:) == 4);
        gyro = stored(k,index + 1 : index + 3);
    else
        gyro = gyro;
    end
    if(size(find(stored(k,:) == 5),2))
        index = find(stored(k,:) == 5);
        mag = stored(k,index + 1 : index + 3);
    else
        mag = mag;
    end
    if(size(find(stored(k,:) == 81),2))
        index = find(stored(k,:) == 81);
        ori = stored(k,index + 1 : index + 3);
    else
        ori = ori;
    end
    if(size(find(stored(k,:) == 82),2))
        index = find(stored(k,:) == 82);
        linacc = stored(k,index + 1 : index + 3);
    else
        linacc = linacc;
    end
    if(size(find(stored(k,:) == 83),2))
        index = find(stored(k,:) == 83);
        grav = stored(k,index + 1 : index + 3);
    else
        grav = grav;
    end
    
    
    fprintf('time:%6.4f ', time);
    fprintf('acc:[%6.4f %6.4f %6.4f] ', acc(:));
    fprintf('gyro:[%6.4f %6.4f %6.4f] ', gyro(:));
    fprintf('mag:[%6.4f %6.4f %6.4f] ', mag(:));
    fprintf('ori:[%6.4f %6.4f %6.4f] ', ori(:));
    fprintf('linacc:[%6.4f %6.4f %6.4f] ', linacc(:));
    fprintf('grav:[%6.4f %6.4f %6.4f]\n', grav(:));
    
    rotators(k,:) = eulerd(fuse_ILKF(acc,gyro,mag),'XYZ','frame');
    q(k,:) = eulerd(fuse_CF(acc,gyro),'XYZ','frame');
    
    k = k + 1;
    
end

timeStamp = data(:,1);
time_size = size(timeSamp,1);
time_axis = zeros(time_size,1);

for i = 1:1:time_size
    time_axis(i,1) = timeStamp(i,1) - timeStamp(1); %offset.
end

% Close all instruments
fclose(instrfindall);