function X_f = exponentialSampling(~)
    %实现课件中的方法一指数分布抽样
    n = 0;
    x_0 = rand;
    while(true)
        i = 0;
        x_minus = x_0;
        x_plus = rand;
        while(x_minus > x_plus)
            i = i + 1;
            x_minus = x_plus;
            x_plus = rand;
        end
        if mod(i,2) == 0
            break
        end
        n = n + 1;
    end
    X_f = n + x_0;
end

