inlierTmp = inliers{1};
%inlierTmp = remadj;
[id1, id2]=find(inlierTmp>0);
idxx=union(id1,id2);

figure,imshow(im);
hold on;
plot(LS([1,3],idxx), LS([2,4],idxx), 'Color', 'green', 'LineWidth', 2);