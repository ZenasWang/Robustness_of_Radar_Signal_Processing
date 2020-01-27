function [] = plot_range_DOA(cost_func, u)
contourf(cost_func, 100, 'linestyle', 'none');
axis('equal');
if u == "ux"
    xlabel('ux')
else
    xlabel('uy')
end

ylabel('r0')
xticks('auto')
yticks('auto')
c_r = colorbar;
ylabel(c_r,'beta') 