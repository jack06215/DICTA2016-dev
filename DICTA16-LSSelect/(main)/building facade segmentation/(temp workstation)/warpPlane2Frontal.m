%% Construct homography matrix
close all;
planeID = 1;
ax=X(planeID*2-1);ay=X(planeID*2);az=X3(planeID*3);

%% Ortg 
R1=makehgtform('xrotate',ax,'yrotate',ay);
R3=makehgtform('zrotate',az);
% R1=makehgtform('xrotate',ax,'yrotate',ay,'zrotate',az); 
R1=R1(1:3,1:3);
R3=R3(1:3,1:3);
C_center = [1,0, -center(1);
            0,1, -center(2);
            0,0,1];

K1 = [4.771474878444084e+02,0,0;0,4.771474878444084e+02,0;0,0,1];
%K1 = diag([size(im,2), size(im,2),1]);
  
        
H1= K1*((R3 * R1)/K1)*C_center;
%%
s = norm(H1(:,2)) / norm(H1(:,1));
% det > 0
if (0)
    det = H1(1,1)*H1(2,2) - H1(2,1)*H1(1,2); disp(det);
    if (det <= 0)
        error('det is out of range, program stop');
    else
        disp('det passed');
    end
    % 0 < sqrt(N1_N2) < 1
    N1 = sqrt(H1(1,1)*H1(1,1)+H1(2,1)*H1(2,1)); disp(N1);
    N2 = sqrt(H1(1,2)*H1(1,2)+H1(2,2)*H1(2,2)); disp(N2);
    if (N1 <= 0 || N1 >= 1 || N2 <= 0 || N2 >= 1)
        error('N1/N2 is out of range, program stop');
    else
        disp('N1,N2 passed');
    end
    % 0 < sqrt(N3) < 0.001
    N3 = sqrt(H1(3,1)*H1(3,1)+H1(3,2)*H1(3,2)); disp(N3);
    if (N3 <= 0 || N3 >= 0.0015)
        error('N3 is out of range, program stop');
    else
        disp('N3 passed');
    end
end
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

hFig=[hFig az_fig];
set(hFig(1,end),'Name','Gap Filled and Extended Lines');
imagesc(im_new), axis equal;