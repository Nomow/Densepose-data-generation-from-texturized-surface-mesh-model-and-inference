function [cell_transformed_vertices, cell_transformed_faces] = TransformMeshesOnImgParallel(cell_vertices, cell_faces, bg_im)
    %% transformation
    cell_transformed_vertices = {};
    cell_transformed_faces = {};

    bg_im_width = size(bg_im, 2);
    bg_im_height = size(bg_im, 1);

    % gets min dimensions of images for scaling purposes
    min_dimension = 0;
    if(bg_im_width >= bg_im_height)
        min_dimension = bg_im_height;
    else
        min_dimension = bg_im_width;
    end
    
    scale = min_dimension * randi([2, 10]) / 10;

    temp_z = 0;
    origin = [0,  0, 0];
    im_centroid(1) = randi([1, bg_im_width]);
    im_centroid(2) =  randi([1, bg_im_height]);

    angle_x = randi([-360 360],1);
    angle_y = randi([-360 360],1);
    angle_z = randi([-360 360],1);
    for i = 1:size(cell_vertices,1)
        vertices = cell_vertices{i};
        faces = cell_faces{i};
        % makes mesh of length 1 by z axis to properly scale
        dist_z = abs(max(vertices(:,3)) - min(vertices(:,3)));
        scaled_to_unit_vertices  =  1 / dist_z  * vertices;

        % scales and rotates mesh from 0.3 to 0.9 size of image min dimension
        scaled_vertices =  scale * scaled_to_unit_vertices;
        x_dist = abs(max(scaled_vertices(:,1)) - min(scaled_vertices(:,1)));
        y_dist = abs(max(scaled_vertices(:,2)) - min(scaled_vertices(:,2)));
        
        % rotates around z axis to transfromed mesh in different view
        angle_rot_around_z = randi([-360 360],1);
        rot_around_z_vertices = (rotz(angle_rot_around_z) * scaled_vertices')';
        % flips mesh xyz 
        to_flip_x = randi([0 1],1);
        to_flip_y = randi([0 1],1);
        to_flip_z = randi([0 1],1);
        flipped_vertices = rot_around_z_vertices;
        if(to_flip_x > 0)
            flipped_vertices(:, 1) = -1 * flipped_vertices(:, 1);
        end
        
        if(to_flip_y > 0)
            flipped_vertices(:, 2) = -1 * flipped_vertices(:, 2);
        end
        
        if(to_flip_z > 0)
            flipped_vertices(:, 3) = -1 * flipped_vertices(:, 3);
        end
        
        % origin translate
        center_x = min(flipped_vertices(:,1)) + (max(flipped_vertices(:,1)) - min(flipped_vertices(:,1))) / 2;
        center_y = min(flipped_vertices(:,2)) + (max(flipped_vertices(:,2)) - min(flipped_vertices(:,2))) / 2;
        center_z = min(flipped_vertices(:,3)) + (max(flipped_vertices(:,3)) - min(flipped_vertices(:,3))) / 2;
        centroid  = [center_x, center_y, center_z];
        translation_to_origin_vector = origin - centroid;
        translated_to_origin_vertices = translation_to_origin_vector + flipped_vertices;

        % rotates randomly mesh around x y z axis
    	transformed_vertices = (rotz(angle_z) * roty(angle_y) * rotx(angle_x) * translated_to_origin_vertices')';

        % translates randomly on image and positions meshes so they don't
        % intersect
        fish_im_centroid = im_centroid;
        fish_im_centroid(1) = fish_im_centroid(1) + randi([round(-1 * x_dist / 3), round(x_dist / 3)]);
        fish_im_centroid(2) = fish_im_centroid(2) + randi([round(-1 * y_dist / 3),round(y_dist / 3)]);
        fish_im_centroid(3) = temp_z + abs(max(transformed_vertices(:,3)) - min(transformed_vertices(:, 3)));
        if(fish_im_centroid(1) < 1)
            fish_im_centroid(1) = 1;
        elseif(fish_im_centroid(1) > bg_im_width)
            fish_im_centroid(1) = bg_im_width;
        end
        
        if(fish_im_centroid(2) < 1)
            fish_im_centroid(2) = 1;
        elseif(fish_im_centroid(2) > bg_im_height)
            fish_im_centroid(2) = bg_im_height;
        end
        translated_to_im_center_vertices = (fish_im_centroid - origin) + transformed_vertices;
        temp_z = abs(max(translated_to_im_center_vertices(:,3))) + 10;

        cell_transformed_vertices{i, 1} = translated_to_im_center_vertices;
        cell_transformed_faces{i, 1} = faces;
    end
end

