function V = U_to_V(U)

measurements.pwm = 0:0.1:1;
measurements.voltage = [0.043 0.613 1.768 2.93 4.10 5.26 6.43 7.59 8.80 9.96 11.06];

p = polyfit(measurements.pwm(2:end), measurements.voltage(2:end), 1);

voltage_min = min(measurements.voltage);
PWM_min = (voltage_min - p(2)) / p(1);

voltage = @(PWM) ...
    (PWM < PWM_min) .* (voltage_min) + ...
    (PWM >= PWM_min) .* (p(1) * PWM + p(2));

V = voltage(U);

end

