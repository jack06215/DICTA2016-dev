function [LS,Ladj,LS_c,L,hFig] = lineDetection(im,center,LSDscale,gapfillflag,extendflag,maxlines,athreshgap,dthreshgap,athreshadj,talk)
%LINEDETECTION 
% inputs
% im: image
% LSDscale: scale parameter for the lsd line detector
% gapfillflag: true: fill gaps between lines
% extendflag: true: extend lines
% u0 v0: image center
% outputs
% LS: detected line segments, gap filled and extended
% Ladj: adjacency matrix for line segments
% LS_c: detected line segments in the center coordinates
% L: line segments in vector format
% hFig: the handle of the figures drawn


% Detect and preprocess the lines
[LS,~,Ladj,hFig]=getLSadj(im,LSDscale,gapfillflag,extendflag,maxlines,athreshgap,dthreshgap,athreshadj,talk);  % LS denotes a segment defined by two points

% Move origin to the princple point
LS_c = LS - repmat(center, 2, size(LS, 2));       

% convert line segments to vector format for rectification
L=twopts2L(LS_c);   
end

