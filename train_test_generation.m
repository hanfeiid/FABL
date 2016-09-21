%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:     train_test_generation.m
% Usage:    generating training and testing cases in experiment 
%           using the real-world baxter data for the icra17_fabl paper
% Input:    feature modalities as well as ground truth
% Output:   training and testing labeling
% Author:   Fei Han
% Email:    fhan@mines.edu
% Date:     07/21/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

kActionNum = 8;             % number of action classes
kSubjectNum = 2;            % number of people
kEffortNum = 20;            % times of one person performs one action
kJointNum = 15;             % number of skeletal joints

truth = eye(kActionNum);    % gournd truth

%% Generate all train-test cases.
for train_test_idx = 1: kSubjectNum
    train_raw_feature = [];
    test_raw_feature = [];
    train_truth = [];
    test_truth = [];
    
    for a_idx = 1 : kActionNum
        for e_idx = 1 : kEffortNum
            for s_idx = 1 : kSubjectNum
                path = sprintf('feature_a%02d_s%02d_e%02d.mat',a_idx, s_idx, e_idx);
                file_name = fullfile('feature/', path);
                if ~exist(file_name, 'file')
                    continue;
                end
                
                load(file_name);
    
                % training and testing cases
                if (s_idx == train_test_idx)
                    test_raw_feature  = [test_raw_feature, feature];
                    test_truth = [test_truth, a_idx];
                else
                    train_raw_feature = [train_raw_feature, feature];
                    train_truth = [train_truth, truth(:,a_idx)];
                end
            end
        end
    end
    
    %% save
    save(sprintf('mat/train_test_%d.mat',train_test_idx), ...
        'test_raw_feature','train_raw_feature','test_truth','train_truth', ...
        'binNum_HJPD','binNum_temporal','binNum_temporal0','binNum_dis', ...
        'dim_HJPD','dim_temporal','dim_temporal0','dim_dis');
end