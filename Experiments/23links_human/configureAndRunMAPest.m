clc; close all; clear all;

rng(1); % Force the casual generator to be const
format long;

%% Add src to the path
addpath(genpath('src'));
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

%% Run MAPest main.m
main;