function [im] = MeshesToImg(bg_im, cell_texture_im, cell_dp_u, cell_dp_v, cell_intersecting_faces)
    

    cell_texel_coordinates = {};
    for i = 1:size(cell_intersecting_faces, 1)
        % uv coordinates to texel coordinates
        texture_im_width = size(cell_texture_im{i}, 1);
        texture_im_height = size(cell_texture_im{i}, 2);
        cell_texel_coordinates{i} = round([cell_dp_u{i}, cell_dp_v{i}] .* repmat([texture_im_width, texture_im_height], size(cell_dp_u{i}, 1), 1));
    end
    
    % uv data to img
    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    im = zeros(bg_im_width, bg_im_height , 3);
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    for i = 1:size(cell_intersecting_faces, 1)
        intersecting_faces = cell_intersecting_faces{i};
        intersecting_faces_index = find(~isnan(intersecting_faces));
        pixel_coordinates = im_coords(intersecting_faces_index, :);
        texel_coordinates = cell_texel_coordinates{i};
        for j = 1:size(pixel_coordinates, 1)
            im(pixel_coordinates(j, 1), pixel_coordinates(j, 2), :) = cell_texture_im{i}(texel_coordinates(j, 1), texel_coordinates(j, 2), :);
           % [255. 255. 255]; %flipped_texture_im(texel_coordinates(j, 1), texel_coordinates(j, 2), :);
        end
    end
    % assigns bg values 
    [r, c] = find(sum(im, 3) == 0);
    for i = 1:size(r, 1)
        im(r(i), c(i), :) = bg_im(r(i), c(i), :);
    end
    im = uint8(im);
    %imshow(im);
end

