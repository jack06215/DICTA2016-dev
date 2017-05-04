function horiVerti()
    img = imread('object0008.view04.png');
    img_bw = rgb2gray(img);
    LS = getLines(img_bw, 30);
    LS = LS(:,1:4)';
    %% Filtering
    outliers_model = create_outliers_config(LS);
    %%
    % [x2-x1 y2-y1]
    LS_v = [LS(2,:)-LS(1,:); LS(4,:)-LS(3,:)];
    LS_v = LS_v./repmat(sqrt(sum(LS_v.^2)),2,1);

    horzVector = [1,0];
    vertVector = [0,1];
    imshow(img);
    hold on;
    for i=1:size(LS_v,2)
        horzangle_L = dot(horzVector, abs(LS_v(:,i)));
        vertangle_L = dot(vertVector, abs(LS_v(:,i)));
        if(horzangle_L < vertangle_L)
             plot(LS([1,2],i), LS([3,4],i), 'Color', 'red', 'LineWidth', 2);
        else
            plot(LS([1,2],i), LS([3,4],i), 'Color', 'blue', 'LineWidth', 2);
        end

        if (outliers_model.LS_asin(i) > outliers_model.tau_threshold)
            plot(LS([1,2],i), LS([3,4],i), 'Color', 'green', 'LineWidth', 2);
        end
        drawnow;
    end
    hold off;
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
    outliers_config.tau_threshold = max(sin(pi/60), min(LS_mu + 2 * LS_sigma, sin(pi/10)));
end