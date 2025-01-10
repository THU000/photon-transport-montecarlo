function samples = exponential_random_samples(lambda, n)
    % 检查输入参数是否有效
    if lambda <= 0
        error('Rate parameter lambda must be positive.');
    end
    if n <= 0 || n ~= round(n)
        error('Sample size n must be a positive integer.');
    end
    
    % 生成指数分布的随机样本
    samples = -lambda * log(rand(1, n));
end