function c=orthocost_HR(x,L,K,A,talk)

% computes the cost function of H on line normal vectors
% x 3X3 represents a RECTIFYING homography
% L is 3Xn matrix, containing n lines, the first 2 elements must
% make a unit norm normal vector
% A is the (symmetric) adjacency matrix for planes
% Talk tells the function to print out intermediate results
if nargin<5
    talk=0;
end
if prod(size(x))==9
    Hinv=inv(x);
else
    ax=x(1);ay=x(2);
    %disp(['x-axis:', num2str(ax), ' y-axis:', num2str(ay)]);
    R=makehgtform('xrotate',ax,'yrotate',ay); R=R(1:3,1:3);
    K = [x(3),0,0;0,x(3),0;0,0,1];
    Hinv=K*R'*inv(K);
end

% set up Vi and Vj
Lp = Hinv'*L;
Vp = Lp(1:2,:);

Vp=Vp./repmat(sqrt(sum(Vp.^2)),2,1);

% calculate the cost function
C = (Vp'*Vp).^2;
if (talk)
    disp('Orthogonality Cost matrix');
    disp(C)
end
%C = C-eye(size(C));
C(A<1)=0;
c = sum(sum(C));


if (talk)
    disp('Grid Cost matrix')
    disp(C)
    disp(['Sum of costs: ', num2str(c)]);
end
