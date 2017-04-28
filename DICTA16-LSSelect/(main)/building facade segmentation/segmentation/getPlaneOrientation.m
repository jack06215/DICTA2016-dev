function [X,inliers,numhyp,X3] = getPlaneOrientation(Ladj,L,K,highthresh,numPairs,maxTrials,maxDataTrials,poptype,talk)
%% GETPLANEORIENTATION 
% inputs
% Ladj: adjacency matrix for line segments
% L: line segments in vector format
% K: camera matrix
% outputs
% X: alpha and beta for each plane hypothesis
% inliers: inliers for each plane hypothesis
% numhyp: number of plane hypothesis
%%

% Adjacency matrix is symmetrical, so take the upper part
Ladj=triu(Ladj);

% Output variables
remadj=Ladj;        % remaining adjacency matrix
X=zeros(2,0);       % X and X3 are the axix-angle rotation for rectification result
X3=zeros(3,0);      % Todo: merge X(1:2,:) with X3(3,:) together

numhyp=0;           % number of hypothesis plane detected
inliers=cell(0);    % set of extended line segments pairs that contribute to each plane.

while 1
    % compute a "model" for the hypothesis plane in a given image
    [x,currinliers,x3]=nextRANSAChypo(L,remadj,Ladj,K,highthresh,numPairs,maxTrials,maxDataTrials,poptype,talk);
    
    % update the model information
    inliers=[inliers,currinliers];      % plane inliers
    X=[X,x];                            % angle-axis rotation
    X3=[X3,x3];
    remadj=remadj-currinliers;          % remaining adjacency pairs
    numhyp=numhyp+1;                    % number of plane detected

    % show the inliers' line segments
    [ind1,~]=find(currinliers>0);

    % break if the model is below 10% of the total adjacency
    % pairs
    if length(ind1)<max([10,0.1*sum(sum(Ladj))])
        numhyp=numhyp-1;
        fprintf(1,'<> not enough pairs rectified THIS time\n %d of %d regions rectified\n\n',sum(sum(remadj)),sum(sum(Ladj)));
        break;
    
    % break if there is not enough adjacency for further computation
    % process
    elseif sum(sum(remadj))<max([20,0.1*sum(sum(Ladj))])
        fprintf(1,'<> not enough adjacent pairs remain\n only %d of %d remaining\n\n',sum(sum(remadj)),sum(sum(Ladj)));
        break;
    end
end


end

