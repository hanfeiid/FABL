%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:     main.m
% Usage:    main function in experiment 
%           using the real-world baxter data for the icra17_fabl paper
% Input:    feature modalities as well as ground truth
% Output:   identification results
% Author:   Fei Han
% Email:    fhan@mines.edu
% Date:     07/21/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all
clear all
clc

kIter = 50;                 % max interation number

kActionNum = 8;             % number of action classes
kSubjectNum = 2;            % number of people
kEffortNum = 20;            % times of one person performs one action
kJointNum = 15;             % number of skeletal joints

lambda_joint = 0.1;
lambda_view = 1;

test_result = [];
test_ground_truth = [];

%% iteration
for train_test_idx = 1 : kSubjectNum
    load(sprintf('mat/train_test_%d.mat',train_test_idx));    
    
    X = train_raw_feature;
    Y = train_truth';
    XX = X * X';
    XY = X * Y;
    n = size(X,2);
    b = Y'*ones(n,1)/n;

    onePartNum_HJPD = binNum_HJPD * 3;
    onePartNum_temporal = binNum_temporal * 3;
    onePartNum_temporal0 = binNum_temporal0 * 3;
    onePartNum_dis = binNum_dis;
    view1_N = dim_HJPD;
    view2_N = dim_temporal;
    view3_N = dim_temporal0;
    view4_N = dim_dis;

    
    view_N = [view1_N; view2_N; view3_N; view4_N];
    view_num = 4;
    p = ones(kJointNum,kActionNum);
    v = ones(view_num,kActionNum);
    I1 = ones(onePartNum_HJPD,1);
    I2 = ones(onePartNum_temporal, 1);
    I3 = ones(onePartNum_temporal0, 1);
    I4 = ones(onePartNum_dis, 1);
    
    % initialize W matrix
    W = zeros(size(X,1),size(Y,2));

    obj = zeros(kIter, 1);    
    % iterate until convergence
    for iteration = 1 : kIter
        obj_view = 0;
        obj_joint = 0;

        for i = 1 : kActionNum   % i = 1 : classNum c
            % tree structured norm begin %
            D_joint = diag([kron(p(:,i), I1); kron(p(:,i),I2); ...
                            kron(p(:,i),I3); kron(p(:,i),I4)]);
            D_view = diag([kron(v(1,i), ones(view1_N,1)); ...
                           kron(v(2,i), ones(view2_N,1)); ...
                           kron(v(3,i), ones(view3_N,1)); ...
                           kron(v(4,i), ones(view4_N,1))]);

            W(:,i) = (XX + lambda_joint * D_joint + lambda_view * D_view) ...
                        \ X * (Y(:,i) - b(i));    % Update W_i
            wi = W(:,i);    % one column        

            % Joints
            wi_joint = zeros(onePartNum_HJPD + onePartNum_temporal + ...
                        onePartNum_temporal0 + onePartNum_dis, kJointNum);
            for joint_idx = 1 : kJointNum
                wi_joint(:,joint_idx) = ...
                        [wi((joint_idx-1)*onePartNum_HJPD + 1 ...
                                : joint_idx*onePartNum_HJPD); 
                         wi(view1_N+(joint_idx-1)*onePartNum_temporal+1 ...
                                : view1_N+joint_idx*onePartNum_temporal); 
                         wi(view1_N+view2_N+(joint_idx-1)*onePartNum_temporal0+1 ...
                                : view1_N+view2_N+joint_idx*onePartNum_temporal0);
                         wi(view1_N+view2_N+view3_N+(joint_idx-1)*onePartNum_dis+1 ...
                                : view1_N+view2_N+view3_N+joint_idx*onePartNum_dis)];

                p(joint_idx,i) = 1/(norm(wi_joint(:,joint_idx),2)+eps);
            end

            v(1,i) = 1 / (norm(wi(1:view1_N),2) + eps);
            v(2,i) = 1 / (norm(wi(view1_N+1:view1_N+view2_N),2) + eps);
            v(3,i) = 1 / (norm(wi(view1_N+view2_N+1:view1_N+view2_N+view3_N),2) + eps);
            v(4,i) = 1 / (norm(wi(view1_N+view2_N+view3_N+1 ...
                                   :view1_N+view2_N+view3_N+view4_N),2) + eps);

            % Skeletal joint norm
            for joint_idx = 1 : kJointNum
                obj_joint = obj_joint + norm(wi_joint(:,joint_idx),2);
            end
            obj_joint = obj_joint + 20 * eps;
            % norm of multi-view
            obj_view = obj_view + norm(wi(1:view1_N),2) ...
                + norm(wi(view1_N+1:view1_N+view2_N),2) ...
                + norm(wi(view1_N+view2_N+1:view1_N+view2_N+view3_N),2) ...
                + norm(wi(view1_N+view2_N+view3_N+1:view1_N+view2_N+view3_N+view4_N),2)...
                + 4 * eps;
        end

        % Update objective
        obj(iteration) = 0.5 * norm(X'*W-Y+ones(n,1)*b', 'fro')^2 + ...
                        lambda_joint * obj_joint + lambda_view * obj_view;

        % end condition
        if (iteration > 1 && abs(obj(iteration) - obj(iteration-1)) <= 0.0001)
            break;
        end
    end

    % calc test result
    [~,one_test_result] = max(W'*test_raw_feature+repmat(b,1,size(test_raw_feature,2)));
    test_result = [test_result, one_test_result];
    test_ground_truth = [test_ground_truth, test_truth];

end
        

%%  Drawing confusion matrix
conmat = confusionmat(test_ground_truth, test_result); 
label = {'right arm up', ...
         'left arm up', ...
         'right pour',...
         'left pour', ...
         'right serve', ...
         'left serve', ...
         'right arm down', ...
         'left arm down', ...
         };
n_class = length(conmat);
for i = 1 : n_class
   conmat(i,:) = conmat(i,:) ./ sum(conmat(i,:)); 
end

set(0,'DefaultTextFontName','Times',...
      'DefaultTextFontSize',18,...
      'DefaultAxesFontName','Times',...
      'DefaultAxesFontSize',18,...
      'DefaultLineLineWidth',2,...
      'DefaultLineMarkerSize',7.75)
drawConfusionMatrix(conmat, label);

%% output accuracy
accuracy =  trace(conmat) / (kActionNum);
display(sprintf('The accuracy is %f', accuracy));

