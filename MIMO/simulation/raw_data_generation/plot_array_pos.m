function [] = plot_array_pos(Tx, Rx)

plot(Tx(:,1), Tx(:,2), '*r');
axis('equal')
together = [Tx; Rx];
Lmax = max(together);
xlim([-5, Lmax(1) + 5]);
ylim([-5, Lmax(2) + 5]);
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



