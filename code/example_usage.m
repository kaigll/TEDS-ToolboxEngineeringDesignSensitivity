% Example usage of the simplified TEDS interface
% This shows how to use callTEDS with both FWTtank and Riser examples
%
% Directory structure:
% ./fwt/design_FWTtank.m    - FWT tank design model
% ./riser/design_Riser.m    - Riser design model

% Add all subdirectories to MATLAB's path
current_dir = fileparts(mfilename('fullpath'));
addpath(genpath(current_dir));

%% Example 1: FWTtank Analysis
% Define the model configuration
fwt_config = struct();
fwt_config.h_function = 'design_FWTtank';  % MATLAB will find this in the fwt directory
fwt_config.variables = [
    struct('name', '\rho', 'nominal_value', 1180, 'cov', 1/100)
    struct('name', '\rho_f', 'nominal_value', 1025, 'cov', 1/100)
    struct('name', 'C_a', 'nominal_value', 1, 'cov', 1/100)
    struct('name', 'C_d', 'nominal_value', 1, 'cov', 1/100)
    struct('name', 'L_b', 'nominal_value', 0.15, 'cov', 1/100)
    struct('name', 'r', 'nominal_value', 0.045, 'cov', 1/100)
    struct('name', 't', 'nominal_value', 0.003, 'cov', 1/100)
    struct('name', 'mb', 'nominal_value', 3, 'cov', 1/100)
    struct('name', 'E', 'nominal_value', 3e9, 'cov', 1/100)
];

% Optional: Define custom analysis settings (or use defaults)
fwt_analysis = struct();
fwt_analysis.n_samples = 2000;
fwt_analysis.n_bins = 30;

% Run the analysis
fwt_results = callTEDS(fwt_config, fwt_analysis);

%% Example 2: Riser Analysis
% Define the model configuration
riser_config = struct();
riser_config.h_function = 'design_Riser';  % MATLAB will find this in the riser directory
riser_config.variables = [
    struct('name', 'C_a', 'nominal_value', 1.5, 'cov', 1/5)
    struct('name', 'C_d', 'nominal_value', 1.1, 'cov', 1/2)
    struct('name', '\rho', 'nominal_value', 7.84e3, 'cov', 1/20)
    struct('name', 'E', 'nominal_value', 2e11, 'cov', 1/20)
    struct('name', '\rho_oil', 'nominal_value', 0.92e3, 'cov', 1/10)
    struct('name', 'T_0', 'nominal_value', 4905e3, 'cov', 1/10)
];

% Optional: Define custom analysis settings for Riser
riser_analysis = struct();
riser_analysis.n_samples = 5000;
riser_analysis.n_bins = 40;

% Run the analysis
riser_results = callTEDS(riser_config, riser_analysis);

%% Example 3: Minimal Usage (using all defaults)
% You can also just provide the model configuration and use all default settings
minimal_config = struct();
minimal_config.h_function = 'design_FWTtank';  % MATLAB will find this in the fwt directory
minimal_config.variables = [
    struct('name', '\rho', 'nominal_value', 1180, 'cov', 1/100)
    struct('name', '\rho_f', 'nominal_value', 1025, 'cov', 1/100)
];

% Run with defaults
results = callTEDS(minimal_config); 