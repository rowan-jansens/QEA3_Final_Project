
%% READ IN DATA
data = readtable("btfl_001.csv")

%TRIM DATA
start_idx = 2000
end_idx = 144000

%PLOT TRACK
% plot(data.loopIteration(start_idx:end_idx), data.debug_0_(start_idx:end_idx))

%SAVE KEY TRACKS
gryo_data = [data.debug_0_(start_idx:end_idx) data.debug_1_(start_idx:end_idx) data.debug_2_(start_idx:end_idx)];
throttle = data.rcCommand_3_(start_idx:end_idx);
time = data.time(start_idx:end_idx);

%% SIMPLE FFT PLOT

%DEFINE FFT BOILERPLATE
Fs = 3200;                    % Sampling frequency                    
T = 1/Fs;                     % Sampling period       
L = length(time);             % Length of signal
t = (0:L-1)*T;                % Time vector

%FIGURE SETTINGS
figure(1)
clf
colors = [[0 255 26]./255 ; [255 0 119]./255 ; [0 123 255]./255;  0.1 0.1 0.1];
names = ["Roll", "Pitch", "Yaw"];
set(gcf,'Color','k')
set(gcf, 'InvertHardcopy', 'off');


for i=1:3
    %PERFORM FFT FOR THE THREE GYRO TRACKS
    X = gryo_data(:, i);
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    
    %PLOT
    subplot(3,1,i)
    hold on
    plot(f,P1, "color", colors(i,:), "LineWidth", 0.01) 
    set(gca,'Color', colors(4,:))
    set(gca,'XColor',[1 1 1])
    set(gca,'YColor',[1 1 1])
    ylim([0,1])
    xlim([0,800])
    grid on 
    grid minor


    title(names(i), "Color", [1 1 1])
    xlabel("Frequency (Hz)", "Color", [1 1 1])
    ylabel("Amplitude", "Color", [1 1 1])
    
end

    %SAVE
    print(gcf,'Simpel_Frequ_plot.png','-dpng','-r600')


%% FFT FREQUENCY RESPONCE

%DEFINE SUB-SAMPLE SIZE
sub_sample_size = 600;
total_samples = length(time);

%DEFINE FFT BOILERPLATE
Fs = 3200;                    % Sampling frequency                    
T = 1/Fs;                     % Sampling period       
L = sub_sample_size;          % Length of signal
t = (0:L-1)*T;                % Time vector
f = Fs*(0:(L/2))/L;           %frequency vector

%INITIALIZE EMPTY MATRICIES
data_matrix = zeros(sub_sample_size / 2 + 1, total_samples-sub_sample_size);
throttle_data = zeros(2, total_samples-sub_sample_size);
clean_data = zeros(sub_sample_size / 2 + 1,1000);

%CYCLE THROUGHT DATA
for i = 1:total_samples-sub_sample_size
    
    %PERFORM FFT ON EACH SUB-SAMPLE
    X = gryo_data(i:i+sub_sample_size,2);
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    
    %WRITE FFT TO MATRIX
    data_matrix(:,i) = P1;
    %CALCULATE AVERAGE THROTTLE VALUE OVER SUB-SAMPLE
    throttle_data(:,i) = [round(mean(throttle(i:i+sub_sample_size))) std(throttle(i:i+sub_sample_size))];

end 

disp("done!")

%%

%CYCLE THROUGH EXPECTED THROTTLE RANGE
for i = 1000:2000
    %FIND LINES WITH SAME THROTTLE AND REMOVE LINES WITH HIGH UNCERTANTY
    group = (throttle_data(1,:) == i) & (throttle_data(2,:) < 200);
    %COMBINE FFTs INTO NEW DATA ARRAY
    clean_data(:,i-999) = mean(data_matrix(:,group), 2);
   
end

%CUT OFF HIGH AMPLITUDES
amp_cut_off = 8;
clean_data(clean_data > amp_cut_off) = amp_cut_off;

%USE CONVOLUTION TO REMOVE HIGH FREQUENCY NOISE
clean_data = conv2(clean_data, ones(2,30),'same');

%PLOT
figure(1)
clf
set(gcf,'Color','k')


load("blue.mat")
colormap(blue_map)

surf(f, ([1000:2000]-999)./10, clean_data', "EdgeColor", "none", 'FaceAlpha', 1)
view(0,90)
xlim([0,800])

xlabel("Frequency (Hz)", "Color", [1 1 1])
ylabel("Throttle (%)", "Color", [1 1 1])
title("Frame Resonance Responce", "Color", [1 1 1])

ylim([0,100])
set(gca,'YColor',[1 1 1])
set(gca,'XColor',[1 1 1])
set(gca,'ZColor',[1 1 1])
grid on
grid minor


set(gcf, 'InvertHardcopy', 'off');

print(gcf,'Responce.png','-dpng','-r600')