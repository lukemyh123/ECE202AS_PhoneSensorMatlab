

timeStamp = data(:,1);
time_size = size(timeStamp,1);
time_axis = zeros(time_size,1);

for i = 1:1:time_size
    time_axis(i,1) = timeStamp(i,1) - timeStamp(1); %offset.
end

figure
hold on
plot(time_axis,yaw_pitch_roll_ILKF(:,3));   %plot the roll for ILKF filter
plot(time_axis, yaw_pitch_roll_cf(:,3));    %plot the roll fo CF filter
plot(time_axis, ori_data(:,3));
legend('ILKF','CF','GT');
xlabel('time');
ylabel('roll');
hold off;


%root-mean-squared error 
RMSE_ILKF_yaw = sqrt(mean((yaw_pitch_roll_ILKF(:,1)-ori_data(:,1)).^2,2));
RMSE_ILKF_pitch = sqrt(mean((yaw_pitch_roll_ILKF(:,2)-ori_data(:,2)).^2,2));
RMSE_ILKF_roll = sqrt(mean((yaw_pitch_roll_ILKF(:,3)-ori_data(:,3)).^2,2));

RMSE_CF_yaw = sqrt(mean((yaw_pitch_roll_cf(:,1)-ori_data(:,1)).^2,2));
RMSE_CF_pitch = sqrt(mean((yaw_pitch_roll_cf(:,2)-ori_data(:,2)).^2,2));
RMSE_CF_roll = sqrt(mean((yaw_pitch_roll_cf(:,3)-ori_data(:,3)).^2,2));

figure;
subplot(3,1,3)
plot(time_axis,RMSE_ILKF_roll,time_axis,RMSE_CF_roll);
legend('ILKF','CF');
xlabel('time');
ylabel('RMSE');
title('RMSE roll')

subplot(3,1,2)
plot(time_axis,RMSE_ILKF_pitch,time_axis,RMSE_CF_pitch);
legend('ILKF','CF');
xlabel('time');
ylabel('RMSE');
title('RMSE pitch')

subplot(3,1,1)
plot(time_axis,RMSE_ILKF_yaw,time_axis,RMSE_CF_yaw);
legend('ILKF','CF');
xlabel('time');
ylabel('RMSE');
title('RMSE yaw')