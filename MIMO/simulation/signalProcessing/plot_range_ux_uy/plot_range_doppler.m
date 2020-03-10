function [] = plot_range_doppler(range_doppler, varargin)
x = linspace(-83.2666, 83.2666, size(range_doppler, 2));
y = linspace(0, 160, size(range_doppler, 1));

if nargin == 1
contourf(x, y, range_doppler, 100, 'linestyle', 'none');
axis('equal');
xlabel('vr')
ylabel('r0')
xticks('auto')
yticks('auto')
c_r = colorbar;
ylabel(c_r,'Amplitude') 
end

if nargin == 2
contourf(varargin{1}, x, y, range_doppler, 100, 'linestyle', 'none');
xlabel(varargin{1}, 'v');
ylabel(varargin{1}, 'r0')
c_r = colorbar(varargin{1});
ylabel(c_r,'Amplitude');
end

end