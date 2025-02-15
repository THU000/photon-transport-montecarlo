%蒙特卡洛方法解决光子输运问题，NaI（Tl）
%暂时考虑单一介质
clc;clear;
%常量，变量，初始化
E_electron = 0.511;%电子静止能量，MeV，用于计算alpha
N = 1e6;%模拟的光子数
R = 2.0;%圆柱闪烁体半径，cm
H = 4.0;%圆柱闪烁体高度，cm
D = 20.0;%gamma源距离圆柱闪烁体上表面的距离，cm
Al_thickness = 0.2;%闪烁体外部包覆Al层厚度
r_0 = [0,0,H];%初始位置，入射位置
E_0 = 0.662;%初始能量，MeV
Omega_0 = [0,0,-1];%初始方向，入射方向为向下
E_D = zeros(N,1);%存储每个光子的沉积能量
E_threshold = 1e-4;%能量阈值，判定游动历史是否终止
num_eff = 0;%统计到的光子数量，用于计算探测效率
num_escape = 0;
signal = 0;

%能量和截面数据库
Al_data = readmatrix("Al.xlsx");
NaI_data = readmatrix("NaI.xlsx");

%对 N 个光子进行模拟，得到能谱数据
for k = 1:N
    %进行一次模拟
    %一个光子的模拟流程
    r_m = r_0;
    E_m = E_0;
    Omega_m = Omega_0;
    signal = 0;
    while (E_m > E_threshold)
        %指数分布抽样，确定自由程
        %rho = exponentialSampling();
        %此函数为正确指数分布抽样，上面那个我自己写的，不太对
        rho = exponential_random_samples(1,1);
        %特别判断光子第一次进入探测器，如果输运距离超过 H ，则不记录能量，且不计入探测数
        if rho > 1.0883 && signal == 0 %确保光子是第一次入射状态
            num_escape = num_escape + 1;
            break;
        end
        %根据光子能量插值得到截面数据
        [cross_sections, probabilities] = interpolateSections(E_m, NaI_data);
        %单一介质，确定输运距离
        L = rho / (cross_sections(1) + cross_sections(2));
        %计算下一个碰撞位置
        r_m = r_m + L*Omega_m;
        %判断历史终止条件，是否超出侧边界，是否超出上下表面
        if r_m(3)<=0 || r_m(3)>=H || r_m(1)^2 + r_m(2)^2 >= R^2
            if E_m == E_0 && r_m(1) == 0 && r_m(2) == 0 && ...
                    Omega_m(1)==Omega_0(1) && Omega_m(2)==Omega_0(2) && Omega_m(3) == Omega_0(3)
                num_escape = num_escape + 1;
                break;
            end
            %逃出探测器外部的光子数加一
            num_eff = num_eff + 1;
            %在外部，统计之前的能量沉积
            E_D(k) = E_0 - E_m;
            E_D(k) = normal_distribution(E_D(k));
            break;
        else
            signal = 1;%光子不是第一次入射状态
            %在内部，确定碰撞类型和碰撞方向
            kesi = rand;
            if kesi <= probabilities(2)
                %发生光电效应
                E_D(k) = E_0;%沉积光子所有能量，包括碰撞沉积，也就是原始能量
                E_D(k) = normal_distribution(E_D(k));
                num_eff = num_eff + 1;
                break;
            else
                %算出康普顿散射后的能量
                alpha = E_m / E_electron;
                [E_m, x] = alpha_calculate(alpha,E_m);
                %判断能量如果小于阈值，直接认定历史终止
                if E_m <= E_threshold
                    num_eff = num_eff + 1;
                    E_D(k) = E_0-E_threshold;
                    E_D(k) = normal_distribution(E_D(k));
                    break;
                end
                %计算碰撞后方向，也就是速度Omega_m
                alpha_stroke = alpha / x;
                mu_L = 1 - 1/alpha_stroke + 1/alpha;
                Omega_m = Omega_m_calculate(mu_L, Omega_m);
            end
        end
    end
end

% 绘制能谱图
figure;
h = histogram(E_D, 'BinLimits', [0.002, 0.85], 'BinWidth', 0.002);
hold on;

xlabel('能量(MeV)');
ylabel('光子计数');
title('γ能谱图');
grid on;
h.EdgeColor = 'none';

% 使用 findpeaks 找到峰值
[~, peak_idx] = max(h.Values);
peak_value = h.Values(peak_idx);
peak_energy = mean([h.BinEdges(peak_idx), h.BinEdges(peak_idx+1)]);

% 找到半高宽对应的左右两个能量index
half_peak_value = peak_value / 2;
first_idx = find(h.Values >= half_peak_value, 1, 'first');
last_idx = find(h.Values >= half_peak_value, 1, 'last');

% 如果没有找到，则设置fwhm_energy为NaN
if isempty(first_idx) || isempty(last_idx)
    fwhm_energy = NaN;
else
    % 计算半高宽对应的能量
    fwhm_energy = h.BinEdges(last_idx+1) - h.BinEdges(first_idx);
    % 在全能峰的位置添加一根竖直红色虚线
    peak_energy_line = mean([h.BinEdges(peak_idx), h.BinEdges(peak_idx+1)]);
    plot([peak_energy_line, peak_energy_line], [0, max(h.Values)], '--r');
    % 在能谱图上绘制竖直黄色虚线表示半高宽
    % 左侧半高宽位置
    plot([h.BinEdges(first_idx), h.BinEdges(first_idx)], [0, max(h.Values)], '--m');
    % 右侧半高宽位置
    plot([h.BinEdges(last_idx+1), h.BinEdges(last_idx+1)], [0, max(h.Values)], '--m');
end

% 输出半高宽能量
disp(['FWHM Energy: ', num2str(fwhm_energy), ' MeV']);

%计算峰总比
sigma = 0.4247*fwhm_energy;
peak_left_index = (peak_energy - 3*sigma)/0.002;%全能峰左边
peak_right_index = (peak_energy + 3*sigma)/0.002;%全能峰右边
peak_num_index = h.Values(peak_left_index:peak_right_index);
peak_num = sum(peak_num_index);
peak_total_ratio = peak_num/num_eff;%峰总比

%计算探测效率
detection_eff = num_eff/N;

% 计算能量分辨率
energy_resolution = fwhm_energy / peak_energy * 100; % 以百分比形式表示

% 显示结果
fprintf('全能峰的能量值为: %.4f MeV\n', peak_energy);
fprintf('峰总比为: %.4f \n', peak_total_ratio);
fprintf('探测效率为: %.4f \n', detection_eff);
fprintf('全能峰的半高宽为: %.4f MeV\n', fwhm_energy);
fprintf('能量分辨率为: %.2f%%\n', energy_resolution);

% 清理图形
hold off;

