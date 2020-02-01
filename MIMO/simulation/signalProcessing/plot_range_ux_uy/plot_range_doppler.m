function [] = plot_range_doppler(range_doppler)

x = linspace(-83.2666, 83.2666, size(range_doppler, 2));
y = linspace(0, 160, size(range_doppler, 1));
contourf(x, y, range_doppler, 100, 'linestyle', 'none');
axis('equal');

xlabel('vr')
ylabel('r0')
xticks('auto')
yticks('auto')
c_r = colorbar;
ylabel(c_r,'Amplitude') 

end