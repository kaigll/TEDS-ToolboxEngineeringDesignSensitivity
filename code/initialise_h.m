function [Opts, RandV] = initialise_h(config)
% initialise_h initializes the TEDS toolbox with a configuration struct
% instead of hardcoded cases.
%
% Input:
%   config: A struct containing:
%     - h_function_path: Path to the directory containing h-functions
%     - h_function_name: Name of the h-function to call
%     - variables: Array of structs, each containing:
%       - name: Variable name
%       - nominal_value: Nominal value
%       - cov: Coefficient of variation
%     - distribution_type: Type of distribution ('Normal', 'Lognormal', or 'Gamma')
%
% Output:
%   Opts: Options struct for TEDS
%   RandV: Random variables struct for TEDS

% Add h-function path to MATLAB path
if isfield(config, 'h_function_path')
    addpath(genpath(config.h_function_path));
end

% Initialize RandV struct
RandV.nVar = length(config.variables);
RandV.varName = cell(RandV.nVar, 1);
RandV.vNominal = zeros(RandV.nVar, 1);
RandV.CoV = zeros(RandV.nVar, 1);

% Fill in variable information
for i = 1:RandV.nVar
    var = config.variables(i);
    RandV.varName{i} = var.name;
    RandV.vNominal(i) = var.nominal_value;
    RandV.CoV(i) = var.cov;
end

% Initialize Opts struct
Opts.funName = config.h_function_name;
Opts.distType = config.distribution_type;

% Validate inputs
validateDistributionType(Opts.distType);
validateVariables(RandV);

end

function validateDistributionType(distType)
    validTypes = {'Normal', 'Lognormal', 'Gamma'};
    if ~ismember(distType, validTypes)
        error('Distribution type must be one of: %s', strjoin(validTypes, ', '));
    end
end

function validateVariables(RandV)
    if RandV.nVar < 1
        error('At least one variable must be specified');
    end
    if any(RandV.CoV < 0)
        error('Coefficients of variation must be non-negative');
    end
    if any(isnan(RandV.vNominal)) || any(isinf(RandV.vNominal))
        error('Nominal values must be finite numbers');
    end
end