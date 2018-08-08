function [ result, indices ] = RayMeshIntersection(vertices, faces, ray_point, ray)
     p0 = vertices(faces(:, 1),:);
     p1 = vertices(faces(:, 2),:);
     p2 = vertices(faces(:, 3),:);
     Normalized_ray = Normalize(ray);
     if(HaveGpu)
        gpu = gpuDevice;
        memory_needed = 8 * (size(faces, 1) + 15);
        max_rows = floor(gpu.AvailableMemory * 0.9 / memory_needed ) + 1;
        iteration_counter = 1;
        % calculates number of iterations to iterate through gpu array
        if(size(ray, 1) > max_rows)
            add_to_counter =  floor(size(ray, 1) / max_rows);
            if(mod(size(ray, 1),max_rows) > 0)
                add_to_counter = add_to_counter + 1;
            end
            iteration_counter = iteration_counter + add_to_counter;
        end
        result = cell(iteration_counter, 1);
        indices = cell(iteration_counter, 1);

        arr_divider = floor(size(ray, 1) / iteration_counter) + 1;
        for i = 1:iteration_counter
           % Divides gpu array in pieces to fit in memory
           if(size(Normalized_ray, 1) > i * arr_divider)
               gpu_ray = gpuArray(Normalized_ray(1 + (i - 1) * arr_divider: i * arr_divider, :));
               divided_ray_point = ray_point(1 + (i - 1) * arr_divider: i * arr_divider, :);
           else    
               gpu_ray = gpuArray(Normalized_ray(1 + (i - 1) * arr_divider:end , :));
               divided_ray_point = ray_point(1 + (i - 1) * arr_divider:end, :);
           end
           distance_from_face = arrayfun(@rayTriGPU, p0(:,1)', p0(:,2)', p0(:,3)', ...
                            p1(:,1)', p1(:,2)', p1(:,3)', ...
                            p2(:,1)', p2(:,2)', p2(:,3)', ...
                            divided_ray_point(:,1), divided_ray_point(:,2), divided_ray_point(:,3), ...
                            gpu_ray(:,1),gpu_ray(:,2),gpu_ray(:,3));
           distance = gather(distance_from_face);
           clear distance_from_face
           clear gpu_ray
           [result{i}, indices{i}] = nanmin(abs(distance), [], 2);
           clear distance
        end
     else
        result = cell(size(ray, 1), 1);
        distance = zeros(1, size(faces, 1));
        for i = 1:size(ray, 1)
            for j = 1:size(faces, 1)
                distance_from_face = arrayfun(@rayTriGPU, p0(j,1)', p0(j,2)', p0(j,3)', ...
                            p1(j,1)', p1(j,2)', p1(j,3)', ...
                            p2(j,1)', p2(j,2)', p2(j,3)', ...
                            ray_point(i,1), ray_point(i,2), ray_point(i,3), ...
                            ray(i,1),ray(i,2),ray(i,3));    
                distance(j) = abs(distance_from_face);
            end
             result = nanmin(distance, [], 2);
        end
     end
     indices = cell2mat(indices);
     result = cell2mat(result);
end




