function [segmentation, area] = MeshesSegmentation(cell_intersecting_faces, bg_im);
    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    se = strel('disk',2);
    segmentation = {};
    for i = 1:size(cell_intersecting_faces, 1)
        intersecting_faces = cell_intersecting_faces{i};
        index = find(~isnan(intersecting_faces));
        non_zero_im_coords = im_coords(index, :);
        im = zeros(bg_im_width, bg_im_height);
        
        % assings binary vlaues
        for j = 1:size(non_zero_im_coords, 1)
            im(non_zero_im_coords(j ,1), non_zero_im_coords(j, 2)) = 1;
        end
        im = logical(im);
        
        % closes im to remove any small holes
        closed_im = logical(imclose(im, se));
        area{i, 1} = bwarea(closed_im);
        boundaries = bwboundaries(closed_im);
        segmentation{i , 1} = cell(size(boundaries, 1), 1);
        for j = 1:size(boundaries, 1)
            segmentation{i}{j} = boundaries{j};
        end
        
    end
end

