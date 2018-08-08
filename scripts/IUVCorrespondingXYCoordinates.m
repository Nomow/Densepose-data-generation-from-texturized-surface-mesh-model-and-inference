function [dp_x, dp_y] = IUVCorrespondingXYCoordinates(cell_intersecting_pts, cell_bbox, dp_bbox_width, dp_bbox_height, bg_im)
    dp_x = {};
    dp_y = {};
    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    for i = 1:size(cell_intersecting_pts, 1)
        bbox = cell_bbox{i};
        intersecting_pts_index = find(sum(~isnan(cell_intersecting_pts{i}), 2) > 0);
        img_intersect_coords = im_coords(intersecting_pts_index, :);
        inter_pts_to_bbox = img_intersect_coords - [bbox(1), bbox(2)];
        max_inter_x = max(inter_pts_to_bbox(:, 1));
        max_inter_y = max(inter_pts_to_bbox(:, 2));
        
        % scales points to densepose bbox size
        scale = [dp_bbox_width, dp_bbox_height] ./ [bbox(3), bbox(4)];
        scaled_inter_pts_to_bbox = inter_pts_to_bbox .* scale;
        dp_x{i, 1} = scaled_inter_pts_to_bbox(:, 1);
        dp_y{i, 1} = scaled_inter_pts_to_bbox(:, 2);
    end
end

