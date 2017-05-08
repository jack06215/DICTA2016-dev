%% Set up system environment
addpath(genpath('.'));              % Adding all subfolders to path
ccc;                                % Clear up everything
impath = 'Garfield_Building_Detroit.jpg';       % Set the path of the image
talk = getParameter('talk');        % Flag for internediate output
saveFig = getParameter('saveFig');  % Flag for saving figure
if ~exist(impath,'file')            % check if the image file exists
    error('Please enter a valid image path');
end
warning off all;                    % Turn off warnings
%% Main algorithm pipeline starts from here
tic;
[img,K,center,LS,LS_c,X,Ladj,hFig,L,inliers,numhyp,X3] = computeSegmentation(impath,talk);
toc;
%% Save figures screeshot
if saveFig
    for i = 1:length(hFig)
        name = [impath '_segmentation_' num2str(i) '_' get(hFig(1,i),'Name') '.jpg'];
        print(hFig(i), '-djpeg', name);
    end
end