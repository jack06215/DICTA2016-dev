% Extract the row and column index from inliers
%close all;
[inliers_rows, inliers_cols] = find(inliers{planeID}>0);
inlier = union(inliers_rows, inliers_cols);
LS_inlier = LS(:,inlier);

% convert LS to homogenous coordinate
LS_tmp1 = [LS_inlier(1:2,:);ones(1,size(LS_inlier,2))];
LS_tmp2 = [LS_inlier(3:4,:);ones(1,size(LS_inlier,2))];


% Create homography map
tmp_tform = T1.T';
box_corners = [1,   size(im,2)  ,    1,     size(im,2);
               1,       1,       size(im,1), size(im,1);
               1        1             1         1];
box_corners_p = tmp_tform * box_corners;
box_corners_p = box_corners_p(1:2,:) ./ repmat(box_corners(3,:),2,1);
% find bounding box
x_min = min(box_corners_p(1,:));
y_min = min(box_corners_p(2,:));
tform_bb = [1, 0, -x_min; 0, 1, -y_min; 0, 0, 1];
%tmp_tform = tform_bb * tmp_tform;


% apply transformation matrix to LS
LS_tmp1 = tmp_tform * LS_tmp1;
%LS_tmp1 = LS_tmp1' * tmp_tform;
LS_tmp1 = LS_tmp1 ./ repmat(LS_tmp1(3,:),3,1);
LS_tmp1 = LS_tmp1(1:2,:);

LS_tmp2 = tmp_tform * LS_tmp2;
%LS_tmp2 = LS_tmp2' * tmp_tform;

LS_tmp2 = LS_tmp2 ./ repmat(LS_tmp2(3,:),3,1);
LS_tmp2 = LS_tmp2(1:2,:);

LSp_inlier = [LS_tmp1; LS_tmp2];


hFig=[hFig az_fig];
set(hFig(1,end),'Name','Inliers P');
imagesc(im_new), axis equal;
showLS(LSp_inlier, [0,1,0]);
title(['Inlier P ', num2str(planeID)]);

% Plot inliers result on the image
hFig=[hFig az_fig];
set(hFig(1,end),'Name','Inliers');
imagesc(im), axis equal;
showLS(LS_inlier, [0,1,0]);
title(['Inlier ', num2str(planeID)]);