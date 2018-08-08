function [dp_masks] = MaskIm(cell_mesh_segments ,cell_intersecting_faces, cell_bbox, bg_im, dp_bbox_width, dp_bbox_height)

    dp_masks{size(cell_intersecting_faces, 1), 1} = {};
    masks{size(cell_intersecting_faces, 1), 1} = {};

    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    for i = 1:size(cell_intersecting_faces, 1)
        % retrieves non nan coordinates from intersetions
        unique_segments = size(unique(cell_mesh_segments{i}), 1);
        intersecting_faces = cell_intersecting_faces{i};
        intersecting_faces_index = find(~isnan(intersecting_faces));
        segmented_faces =  cell_mesh_segments{i}(intersecting_faces(intersecting_faces_index));
        non_nan_im_coords = im_coords(intersecting_faces_index, :);

        for j = 1:unique_segments
             empty_im = zeros(bg_im_width, bg_im_height);
             patch_index = find(segmented_faces == j);
             patch_xy = non_nan_im_coords(patch_index, :);
             % segments intersections to img
             for k = 1:size(patch_xy, 1)
             empty_im(patch_xy(k, 1), patch_xy(k, 2)) = 1;
             end
               
             % resizes image for denspose annotation purpose
             bbox = cell_bbox{i};
             segmented_region = empty_im(bbox(1):(bbox(1) + bbox(3)), bbox(2):(bbox(2) + bbox(4)));
             segmented_region_resized = imresize(segmented_region, [dp_bbox_width, dp_bbox_height], 'nearest');
             dp_masks{i, j} = permute(segmented_region_resized, [2, 1]);
             masks{i, j} = permute(segmented_region, [2, 1]);
        end
    end
end

