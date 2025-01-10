function Omega_m = Omega_m_calculate(mu_L, Omega_minus)
    %对phi角抽样
    phi = 2*pi*rand;
    %中间变量
    a = mu_L;
    b = sqrt(1 - a^2);
    c = cos(phi);
    d = sin(phi);
    %存储碰撞前的速度值
    u_minus = Omega_minus(1);
    v_minus = Omega_minus(2);
    w_minus = Omega_minus(3);
    %计算碰撞后的速度
    if u_minus^2 + v_minus^2 <= 1e-3
        u_m = b*c;
        v_m = b*d;
        w_m = a*w_minus;
    else
        u_m = a*u_minus + (-b*c*w_minus*u_minus + b*d*v_minus)/sqrt(u_minus^2 + v_minus^2);
        v_m = a*v_minus + (-b*c*w_minus*v_minus - b*d*u_minus)/sqrt(u_minus^2 + v_minus^2);
        w_m = a*w_minus + b*c*sqrt(u_minus^2 + v_minus^2);
    end
    Omega_m = [u_m, v_m, w_m];
end