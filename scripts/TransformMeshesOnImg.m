function [cell_transformed_vertices, cell_transformed_faces] = TransformMeshesOnImg(cell_vertices, cell_faces, bg_im)
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
    for i = 1:size(cell_vertices,1)
        vertices = cell_vertices{i};
        faces = cell_faces{i};
        % makes mesh of length 1 by z axis to properly scale
        dist_z = abs(max(vertices(:,3)) - min(vertices(:,3)));
        scaled_to_im_vertices  =  1 / dist_z  * vertices;

        % scales and rotates mesh from 0.3 to 0.9 size of image min dimension
        scaled_vertices =  scale * scaled_to_im_vertices;

        % origi translate
        center_x = min(scaled_vertices(:,1)) + (max(scaled_vertices(:,1)) - min(scaled_vertices(:,1))) / 2;
        center_y = min(scaled_vertices(:,2)) + (max(scaled_vertices(:,2)) - min(scaled_vertices(:,2))) / 2;
        center_z = min(scaled_vertices(:,3)) + (max(scaled_vertices(:,3)) - min(scaled_vertices(:,3))) / 2;
        centroid  = [center_x, center_y, center_z];
        translation_to_origin_vector = origin - centroid;
        translated_to_origin_vertices = translation_to_origin_vector + scaled_vertices;

        % rotates randomly mesh around x y z axis
        angle_x = randi([-360 360],1);
        angle_y = randi([-360 360],1);
        angle_z = randi([-360 360],1);
        transformed_vertices = (rotz(angle_z) * roty(angle_y) * rotx(angle_x) * translated_to_origin_vertices')';

        % translates randomly on image and positions meshes so they don't
        % intersect
        im_centroid(1) =  randi([1, bg_im_width]);
        im_centroid(2) =  randi([1, bg_im_height]);
        im_centroid(3) = temp_z + abs(max(transformed_vertices(:,3)) - min(transformed_vertices(:, 3)));
        translated_to_im_center_vertices = (im_centroid - origin) + transformed_vertices;
        temp_z = abs(max(translated_to_im_center_vertices(:,3))) + 10;

        cell_transformed_vertices{i, 1} = translated_to_im_center_vertices;
        cell_transformed_faces{i, 1} = faces;
    end
end

