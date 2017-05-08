function [inliers,H]=findHinliers2(LS,H,L,t,talk)

if nargin<4
    talk=0;
end

% set up Vi and Vj
Lp = inv(H)'*L;
Vp = Lp(1:2,:);
for index=1:size(L,2)
    Vp(:,index) = Vp(:,index)/norm(Vp(:,index));
end

% calculate the cost function
C = (Vp'*Vp).^2;
% C = (C.*(1-C));
% c = sum(sum(C));

inliers = C<=t;

outliers = asin_costraint(LS,inliers);
inliers = inliers - outliers;
[id1, id2]=find(outliers>0);
idxx=union(id1,id2);

save outliers.mat;

end

function [outliers] = asin_costraint(LS,currinliers)
    outliers = zeros(size(currinliers));
    [ind1,ind2]=find(currinliers>0);
    ind=union(ind1,ind2);
    %% Filtering
    
    outliers_model = create_outliers_config(LS);
    %outliers_model.tau_threshold
    
    index = find(outliers_model.LS_asin > outliers_model.tau_threshold);
    
    
     outliers(index,:) = 1;   
     outliers(:,index) = 1;
     
     
    outliers= bitand(currinliers,outliers);
    
    %save outliers_modelLS_asin.mat;
end

function outliers_config = create_outliers_config(LS)

    
    outliers_config.LS_distance = (LS(1,:)-LS(2,:)).^2 + (LS(3,:)-LS(4,:)).^2;
    outliers_config.LS_distance = sqrt(outliers_config.LS_distance);
    % 
    outliers_config.LS_shortLength = [abs(LS(1,:)-LS(2,:));  abs(LS(3,:)-LS(4,:))];
    outliers_config.LS_shortLength = min(outliers_config.LS_shortLength,[],1);
    outliers_config.LS_asin = outliers_config.LS_shortLength./outliers_config.LS_distance;
    outliers_config.LS_asin = real(asin(outliers_config.LS_asin));

    % Average and standard deviation
    LS_mu = mean(outliers_config.LS_asin);
    LS_sigma = std(outliers_config.LS_asin);
    % tau threshold for outliers
    outliers_config.tau_threshold = max(sin(pi/60), min(LS_mu + 2.5 * LS_sigma, sin(pi/10)));
end