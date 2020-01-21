function [] = plot_array_pos(Lmax, Tx, Rx)

plot(Tx(:,1), Tx(:,2), '*r');
axis('equal')
xlim([-3, Lmax + 3])
ylim([-3, Lmax + 3])
xticks('auto')
yticks('auto')
xlabel('x')
ylabel('y')
grid on
hold on;
plot(Rx(:,1), Rx(:,2), '*b')
legend("Tx", "Rx")
hold off

end