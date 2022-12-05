function [spectrum, f] = fft_simple(time, gyro_data, track)

%DEFINE FFT BOILERPLATE
Fs = 3200;                    % Sampling frequency                    
T = 1/Fs;                     % Sampling period       
L = length(time);             % Length of signal
t = (0:L-1)*T;                % Time vector



    %PERFORM FFT FOR THE THREE GYRO TRACKS
    X = gyro_data(:, track);
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;

    spectrum = P1;


end