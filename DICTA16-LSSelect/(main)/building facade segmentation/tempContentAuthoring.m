%% Main function
function tempContentAuthoring()
% Setup workstation
clear; close all;
load matlab.mat % Load Garfield_Building_Detroit.jpg

% Extract angle-axis rotation and K from detected hypothesis plane
[ax,ay,az,K] = extractRotationParam(2, X, X3);

% Obtain homography from the angle-axis rotation parameters
H1 = getHFromAngleAxis(ax, ay, az, center, K);

% Obtain front-facing view image
[im_warp, T1] = findWarppedImage(img, H1);
H_tform = T1.T;
figure, imshow(img);
[pt_X, pt_Y] = getpts;
my_roi = [pt_X(1), pt_X(2);
          pt_Y(1), pt_Y(2);
            1    ,   1    ];
        
hold on;
plot(my_roi(1,:), my_roi(2,:), '*', 'color', 'red');
hold off;   


% Define four corners from the input image
[cols, rows, ~] = size(img);
bb_corners = [0, cols, 0, cols;
              0,  0, rows, rows;
              1,  1,  1,    1];
          
bb_corners_p = homoTrans(H_tform', bb_corners);


x_min = min(bb_corners_p(1,:));
x_max = max(bb_corners_p(1,:));

y_min = min(bb_corners_p(2,:));
y_max = max(bb_corners_p(2,:));

boundingBox = [x_min; y_min; x_max-x_min; y_max-y_min];

translation = [1, 0, -boundingBox(1);
               0, 1, -boundingBox(2);
               0, 0,        1];

H_tform = translation * H_tform';

my_roi_p = homoTrans(H_tform,my_roi);

bb_width_p = my_roi_p(4) - my_roi_p(1);
bb_height_p = my_roi_p(5) - my_roi_p(2);

rect_p = [my_roi_p(1), my_roi_p(1)+bb_width_p, my_roi_p(1), my_roi_p(1)+bb_width_p;
          my_roi_p(2), my_roi_p(2),my_roi_p(2) + bb_height_p, my_roi_p(2) + bb_height_p];
      

figure, imshow(im_warp);
hold on;
plot(rect_p(1,:), rect_p(2,:), '*', 'color', 'red');
hold off;

rect_p = [rect_p; 1,1,1,1];

rect_bkp = homoTrans(inv(H_tform),rect_p);


figure, imshow(img);
hold on;
plot(rect_bkp(1,:), rect_bkp(2,:), '*', 'color', 'green');
hold off;




end


function [im_new, T1] = findWarppedImage(im,H1)
%% Calclating Resultant Translation and Scale
Rect = [0,0,1; size(im,2),0,1; size(im,2),size(im,1),1; 0,size(im,1),1]';
Rect_out = homoTrans(H1, Rect);
%% Fix scaling, based on length.
scale_fac = abs((max(Rect_out(1,2), Rect_out(1,3))- min(Rect_out(1,1), Rect_out(1,4)))/size(im,2));
Rect_out = Rect_out./repmat(scale_fac,3,4);
%% Shift the Rect_out back to "pixel coordinate" w.r.t. Rect
Rect_out(1,2) = Rect_out(1,2) - Rect_out(1,1);
Rect_out(2,2) = Rect_out(2,2) - Rect_out(2,1);
Rect_out(1,3) = Rect_out(1,3) - Rect_out(1,1);
Rect_out(2,3) = Rect_out(2,3) - Rect_out(2,1);
Rect_out(1,4) = Rect_out(1,4) - Rect_out(1,1);
Rect_out(2,4) = Rect_out(2,4) - Rect_out(2,1);
Rect_out(1,1) = Rect_out(1,1) - Rect_out(1,1);
Rect_out(2,1) = Rect_out(2,1) - Rect_out(2,1);
% Conversion: dropping off the 'w coordinate', and transpose
Rect = Rect(1:2,:)'; 
Rect_out = Rect_out(1:2,:)';
%% Fit geometric transform between Rect and Rect_out
T1 = fitgeotrans(Rect,Rect_out,'projective');
im_new = imwarp(im, T1');
end

function [ax,ay,az,K] = extractRotationParam(planeID, X, X3)
ax=X(planeID*3-2);ay=X(planeID*3-1);az=X3(planeID*3);
K= [X(planeID*3),0,0;0,X(planeID*3),0;0,0,1];
end

function H1 = getHFromAngleAxis(ax, ay, az, center, K1)
R1=makehgtform('xrotate',ax,'yrotate',ay);
R3=makehgtform('zrotate',az);
R1=R1(1:3,1:3);
R3=R3(1:3,1:3);
C_center = [1,0, -center(1);
            0,1, -center(2);
            0,0,1];  
        
H1= K1*((R3 * R1)/K1)*C_center;
end

