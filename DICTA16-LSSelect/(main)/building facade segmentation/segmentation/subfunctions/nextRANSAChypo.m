function [x,currinliers,x3]=nextRANSAChypo(LS,L,remadj,alladj,K,highthresh,numPairs,maxTrials,maxDataTrials,poptype,talk)

% hypo2 uses all adjacent pairs to compute inliers in the EM loop but still
% uses only remaining adjacent pairs in RANSAC (need to be changed in RANSAC)
% hypo3: changed to exclude any region processing

[H,currinliers,x]=ransacfitH(L,K,remadj,highthresh,numPairs,poptype,maxTrials,maxDataTrials,talk);
xx = x;
K = [xx(3),0,0;0,xx(3),0;0,0,1];

% EM on inliers and homography
[tempH,tempx]=rectifyOrthoR(L,K,currinliers,xx,0);
[H3,x3] = rectifyInplaneR(L,K,currinliers,0,tempx,talk);
% tempinliers=findHinliers(tempH,L,highthresh).*alladj;
tempinliers=findHinliers2(LS,tempH,L,highthresh).*alladj;

while sum(sum(tempinliers))>sum(sum(currinliers))
    if talk
        fprintf(1,'inliers increase from %d to %d\n',sum(sum(currinliers)),sum(sum(tempinliers)));
    end
    currinliers=tempinliers;
    x=tempx;
    
    % fit new model and inliers
    [tempH,tempx]=rectifyOrthoR(L,K,currinliers,xx,1);
    [H3,x3] = rectifyInplaneR(L,K,currinliers,x3(3),tempx,talk);
%     tempinliers=findHinliers(tempH,L,highthresh).*alladj;
    tempinliers=findHinliers2(LS,tempH,L,highthresh).*alladj;

end

[ind1,ind2]=find(currinliers>0);
ind=union(ind1,ind2);

if talk
    fprintf(1,'----\npercent inliers: %f\n',sum(sum(currinliers))/sum(sum(alladj)));
    fprintf(1,'orthogonal pairs: %d\n',sum(sum(currinliers)));
    fprintf(1,'line inliers: %d\n',length(ind));
    if talk>2, pause, else pause(1), end
end