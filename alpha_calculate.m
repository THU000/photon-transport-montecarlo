function [E_m, x] = alpha_calculate(alpha, E_minus)
    %按照课件上计算 x 的抽样，返回碰撞后的能量值
    x = 0;
    while (x == 0)
        kesi_1 = rand;
        if kesi_1 <= 27/(29 + 4*alpha)
            kesi_2 = rand;
            x_1 = (1+2*alpha)/(1 + 2*alpha*kesi_2);
            %中间变量
            signal_1 = 0.5*(1 + ((alpha + 1 - x_1)/alpha)^2);
            kesi_3 = rand;
            if kesi_3 <= signal_1
                x = x_1;
            end
        else
            kesi_2 = rand;
            x_2 = 1 + 2*alpha*kesi_2;
            %中间变量
            signal_2 = (27*(x_2 - 1)^2)/(4*x_2^3);
            kesi_3 = rand;
            if kesi_3 <= signal_2
                x = x_2;
            end
        end
    end
    E_m = E_minus / x;
end