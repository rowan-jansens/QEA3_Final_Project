
function [spectrum, f] = frequ_responce(time, gyro_data, track, throttle)
%FFT FREQUENCY RESPONCE

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
    X = gyro_data(i:i+sub_sample_size,track);
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    
    %WRITE FFT TO MATRIX
    data_matrix(:,i) = P1;
    %CALCULATE AVERAGE THROTTLE VALUE OVER SUB-SAMPLE
    throttle_data(:,i) = [round(mean(throttle(i:i+sub_sample_size))) std(throttle(i:i+sub_sample_size))];

end 


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
spectrum = clean_data;



disp("done!")
end