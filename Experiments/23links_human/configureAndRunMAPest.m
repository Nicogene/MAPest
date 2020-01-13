clc; close all; clear all;

rng(1); % Force the casual generator to be const
format long;

%% Add src to the path
addpath(genpath('src'));
addpath(genpath('analysisAndPlots'));
addpath(genpath('../../src'));
addpath(genpath('../../external'));

%% Preliminaries
% Create a structure 'bucket' where storing different stuff generated by
% running the code
bucket = struct;

%% Configure
% Root folder of the dataset
bucket.datasetRoot = fullfile(pwd, 'dataFloatingIWear');

% Subject and task to be processed
subjectID = 3;
taskID = 2;

%% Options
opts.analysis_48dofURDF = true;
opts.analysis_66dofURDF = false;

% Option for computing the estimated Sigma (default = FALSE)
opts.Sigma_dgiveny = false;

% Final plots
opts.finalPlot = false;

% Option for comparison fixed vs. floating
opts.fixedVSfloat = false;
opts.fixedVSfloat_iterative = false; % option for iterative testing.
% Every time the code is launched, .mat files in the fixed/floating
% processed folders are automatically deleted.


% Option for stack of task (SOT)
opts.stackOfTaskMAP = false;
% This option is by default set to FALSE to guarantee the back
% compatibility with the old MAP

opts.task1_SOT = true;
if opts.task1_SOT
    % SOT in Task1
    opts.stackOfTaskMAP = true;
else
    % SOT in Task2
    opts.stackOfTaskMAP = false;
end

%% Covariances setting
priors = struct;
priors.acc_IMU     = 1e-3 * ones(3,1);                     %[m^2/s^2]   , from datasheet
% priors.gyro_IMU    = xxxxxx * ones(3,1);                 %[rad^2/s^2] , from datasheet
priors.angAcc      = 1e-6 * ones(3,1); %test
priors.ddq         = 6.66e-3;                              %[rad^2/s^4] , from worst case covariance
priors.foot_fext   = 1e-4 *[59; 59; 36; 2.25; 2.25; 0.56]; %[N^2,(Nm)^2]
priors.noSens_fext = 1e-6 * ones(6,1);

bucket.Sigmad = 1e6;
% low reliability on the estimation (i.e., no prior info on the model regularization term d)

bucket.SigmaD = 1e-4;
% high reliability on the model constraints

% for SOT in Task1
priors.fext_hands     = 1e3  * eye(3);
priors.properDotL_lin = 1e-4 * ones(3,1);

%% Run MAPest main.m
if opts.fixedVSfloat
    if taskID == 4
        fixedBase = 'RightFoot';
    else
        fixedBase = 'LeftFoot';
    end
    main_fixed;
end

% floating-base computation
main_floating;
