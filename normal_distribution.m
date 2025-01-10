function E_stroke = normal_distribution(E)
    %把获得的沉积能量做正态分布处理
    FWHM = 0.01 + 0.05*sqrt(E + 0.4*E^2);
    x = randn;
    sigma = 0.4247*FWHM;
    E_stroke = E + sigma*x;
end