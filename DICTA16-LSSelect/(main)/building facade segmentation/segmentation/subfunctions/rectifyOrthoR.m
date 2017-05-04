function [H,x,fval] = rectifyOrthoR(L,K,A,x0,talk)

% L is the 3XN matrix of lines in P2
% K is the intrinsic camera matrix
% A is the symmetric line adjacency matrix, A(i,j)=1 if planes i,j are
%   [probably] adjacent, 0 otherwise.
% H 3X3 is the rectifying homography constructed out of a given K and
% unknown plane orientation (2 dof)

% disp('GO@!!!!~~~');
if nargin<5
    talk=0;
end
if nargin<4
    x0 = [0;0]; %[rx,ry]
end
if nargin<3
    error('at least three arguments required')
end

if talk>0
    options=optimset( 'Display', 'off', 'MaxIter', 2000, 'TolFun', 10^-200, 'TolX', 10^-10,'MaxFunEvals',10^20, 'LargeScale', 'off');
else
    options=optimset( 'Display', 'off', 'MaxIter', 2000, 'TolFun', 10^-20, 'TolX', 10^-10, 'MaxFunEvals',10^20, 'LargeScale', 'off');
end

[x, fval] = fminunc(@orthocost_HR,x0,options,L,K,A);
% disp('HEREE$#WER');

% disp('NOW123456');
ax=x(1);ay=x(2);
%disp(['x-axis:', num2str(ax), ' y-axis:', num2str(ay), ' fval:', num2str(fval)]);
R=makehgtform('xrotate',ax,'yrotate',ay); R=R(1:3,1:3);
K = [x(3),0,0;0,x(3),0;0,0,1];
H=inv(K*R'*inv(K));

% if talk>0
%     disp(['Cost before rectification: ',num2str(orthocost_HR(x0,L,K,A,0))])
%     disp(['Cost after rectification: ',num2str(orthocost_HR(x,L,K,A,0))])
% end
