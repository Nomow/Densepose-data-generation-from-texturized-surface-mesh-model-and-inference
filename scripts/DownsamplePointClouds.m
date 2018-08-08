function [dp_x, dp_y, dp_i, dp_u, dp_v] = DownsamplePointClouds(dp_x, dp_y, dp_i, dp_u, dp_v)
    % downsample coordinates
    for i = 1:size(dp_x, 1)
        ptCloud = pointCloud([dp_x{i}, dp_y{i}, repmat(0, size(dp_x{i}))]);
        ptCloudOut = pcdownsample(ptCloud,'nonuniformGridSample', 400);
        temp_x = ptCloudOut.Location(:,1);
        temp_y = ptCloudOut.Location(:,2);
        concat_xy = [temp_x, temp_y];
        concat_dp_xy = [dp_x{i}, dp_y{i}];
        index = find((ismember(concat_dp_xy, concat_xy, 'rows')) > 0);
        dp_x{i}= dp_x{i}(index);
        dp_y{i} = dp_y{i}(index);
        dp_i{i} = dp_i{i}(index);
        dp_u{i} = dp_u{i}(index);
        dp_v{i} = dp_v{i}(index);
    end

    for i = 1:size(dp_x)
        if(size(dp_x{i}, 1) > 196)
            rand_permuted_index = randperm(size(dp_x{i},1));
            dp_x{i}= dp_x{i}(rand_permuted_index);
            dp_x{i} = dp_x{i}(1:196);

            dp_y{i}= dp_y{i}(rand_permuted_index);
            dp_y{i} = dp_y{i}(1:196); 

            dp_i{i}= dp_i{i}(rand_permuted_index);
            dp_i{i} = dp_i{i}(1:196); 

            dp_u{i}= dp_u{i}(rand_permuted_index);
            dp_u{i} = dp_u{i}(1:196); 

            dp_v{i}= dp_v{i}(rand_permuted_index);
            dp_v{i} = dp_v{i}(1:196); 
        end
    end

end

