% ģ���˻𷨺���˼·:
% Ϊ���ҳ���������ߵ�ɽ��һȺ�������ڿ�ʼ��û�к��ʵĲ��ԣ�������������˺ܳ�ʱ�䣡
% �����ڼ䣬���ǿ�������ߴ���Ҳ����̤��ƽ��;
% ���ǣ�����ʱ������ţ�����"��������"! ��������ߵķ�����ȥ�����͵�������������塣

% ע����������������⣬ģ���˻𷨲�������ͼ!
% ����Ҫ�߾���: x_tmp = x + rand()-0.5;      % ������,������ȡС�����ļ�λ
% ������ͼ: x_tmp = x + round(rand()-0.5,1); % ����С����ֻ��0.1
% ����ѡ��ͼ: ��ʵ���µ��ú�* ; ���ʸ��µ��ú�*!

clc;
clear;
syms x y;
f =(x+y)^2 + (x+1)^2 + (y+3)^2;

% ��ͼ:ԭʼ3d����ͼ
x = -20:0.1:20;
y = -15:0.1:15;
[X,Y] = meshgrid(x,y); 
Z = (X+Y).^2 + (X+1).^2 + (Y+3).^2;
figure(1);
mesh(X,Y,Z);
xlabel('������x'); ylabel('������y'); zlabel('�ռ�����z');
hold on;
% ��ͼ:ԭʼ��
x0 = 10; y0 = -1.5;
z0 = (x0+y0)^2 + (x0+1)^2 + (y0+3)^2;
plot3(x0,y0,z0,'r*');
hold on    

% ��ʼ��:
% ϣ����Χ����: x��[-20,0.1,20] y��[-15,0,1,15]
x = 10.0;
y = -1.5;
f_min = eval(f);

fprintf('��֪:��ȷ��Сֵ����(0.33333,-1.66667,5.33333)\n')
fprintf('ģ���˻�ʼ:\n')
num = 1000;    % ÿ���¶��µ�������
T_max = 1000;  % ��ʼ����¶�1000
T_min = 0.01;  % ��β��С�¶�0.01
Trate = 0.95;  % �¶��½�����0.95
n = 0;
while T_max > T_min
    %fprintf('��ǰ�¶�:%.5f\n',T_max);
    while n < num
        x_tmp = x + round(rand()-0.5,2);
        y_tmp = y + round(rand()-0.5,2);
        if (x_tmp > -20 && x_tmp < 20) && (y_tmp > -15 && y_tmp < 15)
            f_tmp = (x_tmp+y_tmp)^2 + (x_tmp+1)^2 + (y_tmp+3)^2;
            res = f_tmp - f_min;
            % ��ʵ��: �ҵ���С��ֵ��Ȼ�ø���!
            if res < 0
                f_min = f_tmp;
                x = x_tmp;
                y = y_tmp;
                plot3(x,y,f_min,'r*');
                hold on 
            else
                % ���ʵ�: û�ҵ���С��ֵ��������
                p = exp(-res/T_max);
                if rand() > p  
                    f_min = f_tmp;
                    x = x_tmp;
                    y = y_tmp;
                    plot3(x,y,f_min,'w*');
                    hold on;
                end
            end
        end
        n = n + 1;
    end
    T_max = T_max*Trate;
end
fprintf('���Ƽ�Сֵ����Ϊ:(%.5f,%.5f,%.5f)\n', x, y, f_min);
hold off;
        
                    
    
    
    
    
    
    