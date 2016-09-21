%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:     feature_extraction.m
% Usage:    extract features in experiment 
%           using the real-world baxter data for the icra17_fabl paper
% Input:    raw skeleton data stored in txt files
% Output:   feature modalities
% Author:   Fei Han
% Email:    fhan@mines.edu
% Date:     07/21/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

% load parameters of histograms
load('mat/histogram_boundary.mat');

kActionNum = 8;             % number of action classes
kSubjectNum = 2;            % number of people
kEffortNum = 20;            % times of one person performs one action
kJointNum = 15;             % number of skeletal joints
truth = eye(kActionNum);    % gournd truth

%% Get raw features for each activity sample
for a_idx = 1 : kActionNum
    for e_idx = 1 : kEffortNum
        for s_idx = 1 : kSubjectNum
            resizedFeature = [];
            path = sprintf('s%d_a%d_e%d.txt',s_idx, a_idx, e_idx);
            file_name = fullfile('./dataset/', path);
            
            if ~exist(file_name, 'file')
                continue;
            end
            display(sprintf('We are dealing with file: %s', file_name));

            raw_data = textread(file_name);
            frame_num = size(raw_data,1) / kJointNum;


            joint_data = [];
            feature_HJPD = [];
            feature_temporal = [];
            feature_temporal0 = [];
            feature_dis = [];
            for joint_idx = 1 : kJointNum
                one_joint_data = [];
                result_temporal_angle = [];
                for frame_idx = 1 : frame_num
                    one_joint_data = [one_joint_data; raw_data((frame_idx-1)*kJointNum+joint_idx,3:5)];
                end
                joint_data = [joint_data, one_joint_data];
            end

            result_temporal = joint_data - [joint_data(1,:); joint_data(1:size(joint_data,1)-1,:)];
            result_temporal0 = joint_data - repmat(joint_data(1,:),frame_num,1);

            for joint_idx = 1 : kJointNum

                x_idx = (joint_idx - 1) * 3 + 1;
                y_idx = x_idx + 1;
                z_idx = y_idx + 1;
                x = joint_data(:,x_idx) - joint_data(:,7);
                y = joint_data(:,y_idx) - joint_data(:,8);
                z = joint_data(:,z_idx) - joint_data(:,9);
%                     
                myDistance = sqrt(x.^2+y.^2+z.^2);
                %% spatio displacement: HJPD feature
                binNum_HJPD = 12;
                N_x = (HJPD_x(2,:) - HJPD_x(1,:)) * (3 / binNum_HJPD);  % 3 is the best
                N_y = (HJPD_y(2,:) - HJPD_y(1,:)) * (3 / binNum_HJPD);
                N_z = (HJPD_z(2,:) - HJPD_z(1,:)) * (3 / binNum_HJPD);
                hhist_x = dsp.Histogram(HJPD_x(1,joint_idx)+N_x(joint_idx), ...
                    HJPD_x(2,joint_idx)-N_x(joint_idx), binNum_HJPD, 'Normalize', true);
                hhist_y = dsp.Histogram(HJPD_y(1,joint_idx)+N_y(joint_idx), ...
                    HJPD_y(2,joint_idx)-N_y(joint_idx), binNum_HJPD, 'Normalize', true);
                hhist_z = dsp.Histogram(HJPD_z(1,joint_idx)+N_z(joint_idx), ...
                    HJPD_z(2,joint_idx)-N_z(joint_idx), binNum_HJPD, 'Normalize', true);
                raw_x = step(hhist_x, x);
                raw_x = raw_x - mean(raw_x);
                raw_x = raw_x / norm(raw_x,2);
                raw_y = step(hhist_y, y);
                raw_y = raw_y - mean(raw_y);
                raw_y = raw_y / norm(raw_y,2);
                raw_z = step(hhist_z, z);
                raw_z = raw_z - mean(raw_z);
                raw_z = raw_z / norm(raw_z,2);
                current = [raw_x; raw_y; raw_z];
                feature_HJPD = [feature_HJPD; current];

                %% temporal displacement feature
                binNum_temporal = 13;
                temporal_N_x = (temporal_x(2,:) - temporal_x(1,:)) * (3 / binNum_temporal);
                temporal_N_y = (temporal_y(2,:) - temporal_y(1,:)) * (3 / binNum_temporal);
                temporal_N_z = (temporal_z(2,:) - temporal_z(1,:)) * (3 / binNum_temporal);
                thist_x = dsp.Histogram(temporal_x(1,joint_idx)+temporal_N_x(joint_idx), ...
                    temporal_x(2,joint_idx)-temporal_N_x(joint_idx), binNum_temporal, 'Normalize', true);
                thist_y = dsp.Histogram(temporal_y(1,joint_idx)+temporal_N_y(joint_idx), ...
                    temporal_y(2,joint_idx)-temporal_N_y(joint_idx), binNum_temporal, 'Normalize', true);
                thist_z = dsp.Histogram(temporal_z(1,joint_idx)+temporal_N_z(joint_idx), ...
                    temporal_z(2,joint_idx)-temporal_N_z(joint_idx), binNum_temporal, 'Normalize', true);
                raw_tx = step(thist_x, result_temporal(:,x_idx));
                raw_tx = raw_tx - mean(raw_tx);
                raw_tx = raw_tx / norm(raw_tx,2);
                raw_ty = step(thist_y, result_temporal(:,y_idx));
                raw_ty = raw_ty - mean(raw_ty);
                raw_ty = raw_ty / norm(raw_ty,2);
                raw_tz = step(thist_z, result_temporal(:,z_idx));
                raw_tz = raw_tz - mean(raw_tz);
                raw_tz = raw_tz / norm(raw_tz,2);
                current_temporal = [raw_tx; raw_ty; raw_tz];
                feature_temporal = [feature_temporal; current_temporal];

                %% temporal0 displacement feature
                binNum_temporal0 = 13;
                temporal0_N_x = (temporal0_x(2,:) - temporal0_x(1,:)) * (3 / binNum_temporal0);
                temporal0_N_y = (temporal0_y(2,:) - temporal0_y(1,:)) * (3 / binNum_temporal0);
                temporal0_N_z = (temporal0_z(2,:) - temporal0_z(1,:)) * (3 / binNum_temporal0);
                t0hist_x = dsp.Histogram(temporal0_x(1,joint_idx)+temporal0_N_x(joint_idx), ...
                    temporal0_x(2,joint_idx)-temporal0_N_x(joint_idx), binNum_temporal0, 'Normalize', true);
                t0hist_y = dsp.Histogram(temporal0_y(1,joint_idx)+temporal0_N_y(joint_idx), ...
                    temporal0_y(2,joint_idx)-temporal0_N_y(joint_idx), binNum_temporal0, 'Normalize', true);
                t0hist_z = dsp.Histogram(temporal0_z(1,joint_idx)+temporal0_N_z(joint_idx), ...
                    temporal0_z(2,joint_idx)-temporal0_N_z(joint_idx), binNum_temporal0, 'Normalize', true);
                raw_t0x = step(t0hist_x, result_temporal0(:,x_idx));
                raw_t0x = raw_t0x - mean(raw_t0x);
                raw_t0x = raw_t0x / norm(raw_t0x,2);
                raw_t0y = step(t0hist_y, result_temporal0(:,y_idx));
                raw_t0y = raw_t0y - mean(raw_t0y);
                raw_t0y = raw_t0y / norm(raw_t0y,2);
                raw_t0z = step(t0hist_z, result_temporal0(:,z_idx));
                raw_t0z = raw_t0z - mean(raw_t0z);
                raw_t0z = raw_t0z / norm(raw_t0z,2);
                current_temporal0 = [raw_t0x; raw_t0y; raw_t0z];
                feature_temporal0 = [feature_temporal0; current_temporal0];

                %% distance feature
                binNum_dis = 12;
                dis_N = (distance_(2,:) - distance_(1,:)) * (3 / binNum_dis);  % 3 is the best
                dishist = dsp.Histogram(distance_(1,joint_idx)+dis_N(joint_idx), ...
                    distance_(2,joint_idx)-dis_N(joint_idx), binNum_dis, 'Normalize', true);
                raw_d = step(dishist, myDistance);
                raw_d = raw_d - mean(raw_d);
                raw_d = raw_d / norm(raw_d,2);
                feature_dis = [feature_dis; raw_d];


            end

            % concatenate feature modalities
            feature = [feature_HJPD; feature_temporal; feature_temporal0; feature_dis];

            dim_HJPD = size(feature_HJPD,1);
            dim_temporal = size(feature_temporal,1);
            dim_temporal0 = size(feature_temporal0,1);
            dim_dis = size(feature_dis,1);
            
            % save feature modalities
            if ~exist('feature', 'dir')
                mkdir('./feature');
            end
            save(sprintf('feature/feature_a%02d_s%02d_e%02d.mat',a_idx, s_idx, e_idx), ...
                'feature','binNum_HJPD','binNum_temporal','binNum_temporal0','binNum_dis', ...
                'dim_HJPD','dim_temporal','dim_temporal0','dim_dis');
        end
    end
end
    

