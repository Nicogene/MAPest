
% Copyright (C) 2019 Istituto Italiano di Tecnologia (IIT)
% All rights reserved.
%
% This software may be modified and distributed under the terms of the
% GNU Lesser General Public License v2.1 or any later version.

function [ implFeetConstraintForm ] = computeImplicitFeetConstraintForm( kynDynComputation, G_T_base, state, baseVel)
%COMPUTEIMPLICITFEETCONSTRAINTFORM computes the term
%                     pinv(N*B) * N
% which makes the dynamics of the system to satisfy the 2-feet contact
% constraint.
%
% Inputs:
%  - kinDynComputation: berdy object
%  - G_T_base         : berdy Transform of the base of the model w.r.t.
%                       the inertial frame
%  - state            : Matlab struct containing q and dq
%  - baseVel          : 6D base velocity
% Outputs:
%  - implFeetConstraintForm:   pinv(N*B)* N
%                              being N the null space projector of J_feet,
%                              weighted by inv(M) and B a matrix selector.

% Identity matrix (n+6)x(n+6)
identityMatrix = eye(kynDynComputation.getNrOfDegreesOfFreedom+6);

% Mass matrix (n+6)x(n+6)
iDynTreeMassMatrix = iDynTree.FreeFloatingMassMatrix(kynDynComputation.model());
kynDynComputation.getFreeFloatingMassMatrix(iDynTreeMassMatrix);
massMatrix =iDynTreeMassMatrix.toMatlab();

% Selector matrix (O{nx6},1{n})'
selectorMatrix = [zeros(6,kynDynComputation.getNrOfDegreesOfFreedom); ...
    eye(kynDynComputation.getNrOfDegreesOfFreedom)];

% Compute the Jacobians for the feet contact points (i.e., J_feet)
iDynTreeJacobian = iDynTree.FrameFreeFloatingJacobian(kynDynComputation.model);
iDynTreeJacobian.zero();

q  = iDynTree.JointPosDoubleArray(kynDynComputation.model);
dq = iDynTree.JointDOFsDoubleArray(kynDynComputation.model);
baseVelocity = iDynTree.Twist();

% gravityZero = iDynTree.Vector3();
% gravityZero.zero();
gravity = iDynTree.Vector3();
gravity.fromMatlab([0; 0; -9.81]);

samples = size(state.q ,2);
implFeetConstraintForm = cell(samples,1);

kinDynCompLF = kynDynComputation;
kinDynCompRF = kynDynComputation;

iDynTreeJacobianLF = iDynTree.FrameFreeFloatingJacobian(kinDynCompLF.model);
iDynTreeJacobianLF.zero();
iDynTreeJacobianRF = iDynTree.FrameFreeFloatingJacobian(kinDynCompRF.model);
iDynTreeJacobianRF.zero();

for i = 1 : samples
    q.fromMatlab(state.q(:,i));
    dq.fromMatlab(state.dq(:,i));
    baseVelocity.fromMatlab([baseVel.baseLinVelocity(:,i);baseVel.baseAngVelocity(:,i)]);
    
    kinDynCompLF.setRobotState(G_T_base.G_T_b{i,1},q,baseVelocity,dq,gravity);
    kinDynCompLF.getFrameFreeFloatingJacobian('LeftFoot', iDynTreeJacobianLF);
    kinDynCompRF.setRobotState(G_T_base.G_T_b{i,1},q,baseVelocity,dq,gravity);
    kinDynCompRF.getFrameFreeFloatingJacobian('RightFoot', iDynTreeJacobianRF);
    
    fullJacobianLF = iDynTreeJacobianLF.toMatlab();
    fullJacobianRF = iDynTreeJacobianRF.toMatlab();
    
    J_feet = [fullJacobianLF; fullJacobianRF];
    
    % Compute the N null space projector of J_feet, i.e.,
    % N:=[1 - J_feet' inv(J_feet inv(M) J_feet') J_feet inv(M)]
    nullProj_N = identityMatrix - J_feet' /((J_feet /massMatrix) * J_feet') * ...
        J_feet /massMatrix;
    
    % Compute the term for the implicit feet constraint:   pinv(N*B)* N
    implFeetConstraintForm{i,:} = pinvDamped(nullProj_N * selectorMatrix, 1e-8) * nullProj_N;
end
end
