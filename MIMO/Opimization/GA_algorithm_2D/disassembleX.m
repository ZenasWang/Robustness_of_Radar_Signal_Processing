function [Tx, Rx] = disassembleX(x, radarParameter)

N_Tx = radarParameter.N_Tx/2;
N_Rx = radarParameter.N_Rx;

Tx = [0,0; [x(1:N_Tx-1).', x(N_Tx:2*N_Tx-2).']];
Rx = [x(2*N_Tx-1 : 2*N_Tx+N_Rx-2).', x(2*N_Tx+N_Rx-1:2*N_Tx+2*N_Rx-2).'];
end