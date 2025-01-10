function [cross_sections, probabilities] = interpolateSections(energy, matrix_data)
   %给定的能量值
   given_energy = energy;
   energy_data = matrix_data(:,1);
   compton_sections = matrix_data(:,2);
   photon_elec_sections = matrix_data(:,3);
   if given_energy < energy_data(1) || given_energy > energy_data(end)
       error('给定能量超出数据表范围！')
   end
   if given_energy == energy_data(1)
       %端点处能量截面
       cross_sections = [matrix_data(1,2),matrix_data(1,3)];
       total_section = cross_sections(1)+compton_sections(2);
       probabilities_1 = cross_sections(1) / total_section;
       probabilities_2 = cross_sections(2) / total_section;
       %返回反应概率值，[康普顿，光电]
       probabilities = [probabilities_1, probabilities_2];
   elseif given_energy == energy_data(end)
       %端点
       cross_sections = [matrix_data(end,2),matrix_data(end,3)];
       total_section = cross_sections(1)+compton_sections(2);
       probabilities_1 = cross_sections(1) / total_section;
       probabilities_2 = cross_sections(2) / total_section;
       %返回反应概率值，[康普顿，光电]
       probabilities = [probabilities_1, probabilities_2];
   else
       for i = 1:length(energy_data)-1
           if given_energy >= energy_data(i) && given_energy <= energy_data(i+1)
               %找到能量区间
               lower_energy = energy_data(i);
               upper_energy = energy_data(i+1);
               lower_compton_section = compton_sections(i);
               lower_photon_elec_section = photon_elec_sections(i);
               upper_compton_section = compton_sections(i+1);
               upper_photon_elec_section = photon_elec_sections(i+1);
               %计算线性插值
               slope_compton = (upper_compton_section - lower_compton_section)/...
                   (upper_energy - lower_energy);
               slope_photon = (upper_photon_elec_section - lower_photon_elec_section)/...
                   (upper_energy - lower_energy);
               interpolate_compton_section = lower_compton_section + slope_compton*...
                   (given_energy - lower_energy);
               interpolate_photon_section = lower_photon_elec_section + slope_photon*...
                   (given_energy - lower_energy);
               %返回插值计算的截面值[康普顿，光电]
               cross_sections = [interpolate_compton_section, interpolate_photon_section];
               total_section = interpolate_photon_section + interpolate_compton_section;
               probabilities_1 = interpolate_compton_section / total_section;
               probabilities_2 = interpolate_photon_section / total_section;
               %返回反应概率值，[康普顿，光电]
               probabilities = [probabilities_1, probabilities_2];
           end
       end
   end
end
