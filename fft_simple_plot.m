function fft_simple_plot(P1, f, p_color)

    plot(f,P1, "color", p_color, "LineWidth", 0.01) 
    set(gca,'Color', [0.1 0.1 0.1])
    set(gca,'XColor',[1 1 1])
    set(gca,'YColor',[1 1 1])
    ylim([0,1])
    xlim([0,800])
%     xlabel("Frequency (Hz)", "Color", [1 1 1])
% 
%     
%     ylabel("Amplitude", "Color", [1 1 1])
    grid on 
    grid minor
end