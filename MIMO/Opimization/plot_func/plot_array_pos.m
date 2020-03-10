function [] = plot_array_pos(Tx, Rx)

plot(Tx(:,1), Tx(:,2), '*r');
axis('equal')
together = [Tx; Rx];
Lmax = max(together);
xlim([-1, Lmax(1) + 1]);
ylim([-1, Lmax(2) + 1]);
xticks('auto')
yticks('auto')
xlabel('x  unit: 1/2{\lambda}')
ylabel('y  unit: 1/2{\lambda}')
grid on
hold on;
plot(Rx(:,1), Rx(:,2), '*b')
legend("Tx", "Rx")
hold off

end



