function [Tx, Rx] = random_arrays_2D(Lmax, N_Tx, N_Rx, P_plot)
% a function to generate uniform array
% return Tx and Rx array
Tx = Lmax * rand(N_Tx, 2);
Rx = Lmax * rand(N_Rx, 2);

if P_plot
    plot(Tx(:,1), Tx(:,2), '*r');
    hold on;
    plot(Rx(:,1), Rx(:,2), '*b');
    hold off
    axis([-1, Lmax+1, -1, Lmax+1], 'equal')
    
end
end