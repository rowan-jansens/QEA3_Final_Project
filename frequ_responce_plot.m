
function frequ_responce_plot(data, f)


load("blue.mat");
colormap(blue_map)

surf(f, ([1000:2000]-999)./10, data', "EdgeColor", "none", 'FaceAlpha', 1)
view(0,90)
xlim([0,800])

xlabel("Frequency (Hz)", "Color", [1 1 1])
ylabel("Throttle (%)", "Color", [1 1 1])


ylim([0,100])
set(gca,'YColor',[1 1 1])
set(gca,'XColor',[1 1 1])
set(gca,'ZColor',[1 1 1])
grid on
grid minor

end