function [] = plot_range_DOA(cost_func, u)
% a function to plot range_DOA figure
% cost_func: matrix from signal processing
% u: ux or uy, string

if u == "ux"
    x = linspace(-1, 1, size(cost_func, 2));
    xlabel('ux')
else
    x = linspace(-1, 1, size(cost_func, 2));
    xlabel('uy')
end
y = linspace(0, 160, size(cost_func, 1));
contourf(x, y, cost_func, 100, 'linestyle', 'none');
% axis('equal');
ylabel('r0')
xticks('auto')
yticks('auto')
c_r = colorbar;
ylabel(c_r,'beta') 