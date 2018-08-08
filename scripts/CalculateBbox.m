% cell_intersection_distance - intersection of image coordinates with all
% meshes (returned by ImgIntersectionWithMeshes method)
% returns bbox - minx, miny, width height
function [cell_bbox] = CalculateBbox(cell_img_mesh_intersection, bg_im)
    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    cell_bbox = {};
    for i = 1:size(cell_img_mesh_intersection, 1)
      intersection_index = find(~isnan(cell_img_mesh_intersection{i}));
      intersecting_im_coords = im_coords(intersection_index, :);
      cell_bbox{i, 1} = zeros(4, 1);
      cell_bbox{i}(1) = min(intersecting_im_coords(:,1));
      cell_bbox{i}(2) = min(intersecting_im_coords(:,2));
      cell_bbox{i}(3) = abs(max(intersecting_im_coords(:,1)) - min(intersecting_im_coords(:,1)));
      cell_bbox{i}(4) = abs(max(intersecting_im_coords(:,2)) - min(intersecting_im_coords(:,2)));
    end

end

