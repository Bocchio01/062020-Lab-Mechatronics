function [x_eq, u_eq, A, B, C, D] = controllers_design_init(z_star, nDOF)

if (nargin == 1)
    nDOF = 1;
end

try
    currentActiveChoice = get_param("System/Plant (G)", "LabelModeActiveChoice");
catch
    currentActiveChoice = 'Lagrangian model';
end

switch currentActiveChoice
    case 'Literature model'
        [x_eq, u_eq] = operating_point_literature(z_star);
        [A, B, C, D] = ABCD_literature(x_eq, u_eq);

    otherwise
        [x_eq, u_eq] = operating_point_lagrangian(z_star);
        [A, B, C, D] = ABCD_lagrangian(x_eq, u_eq);
end

switch nDOF
    case 1
        A = A(1:3, 1:3);
        B = B(1:3, 1);
        C = C(1, 1:3);
        D = D(1, 1);

        x_eq = x_eq(1:3);
        u_eq(2) = 0;

    case 2
        % Do nothing, ABCD_* already consider the complete 2EM model
end

end

