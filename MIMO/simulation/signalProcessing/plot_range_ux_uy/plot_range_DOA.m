function [] = plot_range_DOA(cost_func, u, varargin)
% a function to plot range_DOA figure
% cost_func: matrix from signal processing
% u: ux or uy, string
if u == "ux"
    x = linspace(-1/2, 1/2, size(cost_func, 2));
    u = 'ux';
else
    x = linspace(0, 0.5, size(cost_func, 2));
    u = 'uy';
end
y = linspace(0, 160, size(cost_func, 1));

if nargin == 2
contourf(x, y, cost_func, 100, 'linestyle', 'none');
xlabel(u);
ylabel('r0')
xticks('auto')
yticks('auto')
c_r = colorbar;
ylabel(c_r,'beta') 
end

if nargin == 3
contourf(varargin{1}, x, y, cost_func, 100, 'linestyle', 'none');
xlabel(varargin{1}, u);
ylabel(varargin{1}, 'r0')
c_r = colorbar(varargin{1});
ylabel(c_r,'beta')
end

% axis('equal');
