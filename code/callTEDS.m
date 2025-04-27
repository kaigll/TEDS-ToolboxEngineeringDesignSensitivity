% callTEDS.m calls the TEDS, toolbox for engineering design, and wraps
% around any blackbox functions/models/digital twins, to estimate the
% sensitivities to uncertainties

% 03/07/2020 @ Franklin Court, Cambridge  [J Yang] --> start with scalar parameter case
% 10/08/2020 @ Franklin Court, Cambridge  [J Yang] --> add option whether
% to normalise Fisher matrix with isNorm variable
% 22/04/2021 @ Franklin Court, Cambridge  [J Yang] --> in TEDS form 
% 04/05/2021 @ Franklin Court, Cambridge  [J Yang] --> add case for Riser 


% Notes: to run the offshore example cases, please download the CHAOS code
% from the repository 'https://github.com/longitude-jyang/hydro-suite', where the blackbox h
% function refers to. 

function [results] = callTEDS(model_config, analysis_config)
% callTEDS.m calls the TEDS toolbox for engineering design sensitivity analysis
% 
% Input:
%   model_config: A struct containing model configuration:
%     - h_function: Name of the h-function to call (e.g., 'design_FWTtank')
%     - variables: Array of structs with fields:
%         - name: Variable name
%         - nominal_value: Nominal value
%         - cov: Coefficient of variation
%
%   analysis_config (optional): A struct containing analysis settings:
%     - n_samples: Number of Monte Carlo samples (default: 2000)
%     - n_bins: Number of bins for histogram (default: 30)
%     - distribution: Distribution type (default: 'Normal')
%     - normalize_fisher: Fisher matrix normalization (default: 1)
%     - kpi_threshold: Threshold for KPI analysis (default: 80)
%     - is_percentile: Whether threshold is percentile (default: true)
%
% Output:
%   results: Struct containing analysis results
%     - sensitivity: KPI-free sensitivity results
%     - kpi: KPI-based sensitivity results
%     - monte_carlo: Monte Carlo simulation results

% Set default analysis configuration if not provided
if nargin < 2
    analysis_config = struct();
end

% Set default values for analysis configuration
if ~isfield(analysis_config, 'n_samples')
    analysis_config.n_samples = 2000;
end
if ~isfield(analysis_config, 'n_bins')
    analysis_config.n_bins = 30;
end
if ~isfield(analysis_config, 'distribution')
    analysis_config.distribution = 'Normal';
end
if ~isfield(analysis_config, 'normalize_fisher')
    analysis_config.normalize_fisher = 1;
end
if ~isfield(analysis_config, 'kpi_threshold')
    analysis_config.kpi_threshold = 80;
end
if ~isfield(analysis_config, 'is_percentile')
    analysis_config.is_percentile = true;
end

% Validate required model configuration
if ~isfield(model_config, 'h_function') || ~isfield(model_config, 'variables')
    error('model_config must contain h_function and variables fields');
end

% Create configuration for initialise_h
config = struct();
config.h_function_name = model_config.h_function;
config.h_function_path = fileparts(which(model_config.h_function));
config.distribution_type = analysis_config.distribution;
config.variables = model_config.variables;

% Initialize TEDS with the configuration
[Opts, RandV] = initialise_h(config);

% Set Monte Carlo and Sensitivity analysis options from config
Opts.nSampMC = analysis_config.n_samples;
Ny = analysis_config.n_bins;
isNorm = analysis_config.normalize_fisher;

% Prepare random samples
[ListPar, parJ] = parList(Opts, RandV, isNorm);
[nPar, ~] = size(ListPar);
nS = Opts.nSampMC;
[xS, ListPar] = parSampling(ListPar, nPar, nS);

% Run Monte Carlo Analysis
disp('Monte Carlo Analysis Starts: ...')
tic;
h_Results = cal_h(xS, Opts);
y = h_Results.y;
[xS, y] = parFilter(xS, y);
elapseTime = floor(toc*100)/100;
disp(strcat('Analysis Completed: ', num2str(elapseTime), '[s]'))

% Run KPI-free Sensitivity Analysis
disp('KPI-free Sensitivity Analysis Starts: ...')
tic;
[yjpdf, V_e, D_e] = calSen_KPIfree(y, xS, nPar, Ny, ListPar, parJ, isNorm);
elapseTime = floor(toc*100)/100;
disp(strcat('Analysis Completed: ', num2str(elapseTime), '[s]'))

% Run KPI-based Sensitivity Analysis
disp('KPI-based Sensitivity Analysis Starts: ...')
tic;
[pF, pFMean, pFSen] = calSen_KPI(y, analysis_config.kpi_threshold, ...
    analysis_config.is_percentile, size(y,2), xS);
elapseTime = floor(toc*100)/100;
disp(strcat('Analysis Completed: ', num2str(elapseTime), '[s]'))

% Store results
results = struct();
results.sensitivity.eigenvectors = V_e;
results.sensitivity.eigenvalues = D_e;
results.sensitivity.pdf = yjpdf;
results.kpi.probability = pF;
results.kpi.mean = pFMean;
results.kpi.sensitivity = pFSen;
results.monte_carlo.samples = xS;
results.monte_carlo.response = y;
results.parameters = RandV;

% Display sensitivity results
displaySen_KPIfree(D_e, V_e, nPar, RandV)
end
