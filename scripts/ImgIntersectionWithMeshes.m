% cell_vertices, cell_faces = m x 1 cells of vertices and faces of meshes
% output all image coordinates, distance to intersection for each mesh faces and intersecting faces 
function [cell_intersection_point, cell_intersecting_faces] = ImgIntersectionWithMeshes(cell_vertices, cell_faces, bg_im)

    
    % concatenates cell vertices and faces together, to determine visible faces in image 
    concat_vertices = [];
    concat_faces = [];
    vertices_count = 0;
    for i = 1:size(cell_faces, 1)
        concat_vertices = [concat_vertices; cell_vertices{i}];
        concat_faces = [concat_faces; (cell_faces{i} + vertices_count)];
        vertices_count = size(concat_vertices, 1);
    end

    % creates rays - each ray starting point is im coordinate, and ray
    % direction is parallel to positive z axis
    bg_im_width = size(bg_im, 1);
    bg_im_height = size(bg_im, 2);
    
    min_x = {};
    max_x = {};
    min_y = {};
    max_y = {};
    im_coords_bbox = [];
    for i = 1:size(cell_faces, 1)
        min_x{i} = round(min(cell_vertices{i}(:,1)));
        max_x{i} = round(max(cell_vertices{i}(:,1)));
        min_y{i} = round(min(cell_vertices{i}(:,2)));
        max_y{i} = round(max(cell_vertices{i}(:,2)));

        if(min_x{i} < 1)
            min_x{i} = 1;
        end

        if(min_y{i} < 1)
            min_y{i} = 1;
        end

        if(max_x{i} > bg_im_width)
            max_x{i} = bg_im_width;
        end

        if(max_y{i} > bg_im_height)
            max_y{i} = bg_im_height;
        end
        im_coords_bbox = [im_coords_bbox; combvec(min_x{i}:max_x{i}, min_y{i}:max_y{i})'];
    end
    unique_im_coords_bbox = unique(im_coords_bbox, 'rows');
    im_coords = combvec(1:bg_im_width, 1:bg_im_height)';
    ray_point = unique_im_coords_bbox;
    ray_point(:,3) = 0;
    ray = repmat([0,0,1], size(ray_point, 1), 1);

    % intersection
    [disttointer, interfaces] = ray_mesh_intersection(concat_vertices, concat_faces, ray_point, ray);
    dist_to_intersection = nan(size(im_coords, 1), 1);
    intersecting_faces = nan(size(im_coords, 1), 1);
    for i = 1:size(disttointer, 1)
        if(~isnan(disttointer(i)))
            index = bg_im_width * (unique_im_coords_bbox(i, 2) - 1) + unique_im_coords_bbox(i, 1);
            dist_to_intersection(index) = disttointer(i);
            intersecting_faces(index) = interfaces(i);
        end
    end
    dist_from_intersection_index = find(~isnan(dist_to_intersection));
    nonNan_intersecting_faces = dist_from_intersection_index;
    ray_point = im_coords;
    ray_point(:,3) = 0;
    ray = repmat([0,0,1], size(ray_point, 1), 1);


    % converts back from concatenated mesh to separate meshes
    cell_intersection_point = {};
    cell_intersecting_faces = {};
    from_face = 0;
    for i = 1:size(cell_faces, 1)
        to_face = from_face + size(cell_faces{i}, 1);
        ith_mesh_intersections = find(from_face < intersecting_faces(nonNan_intersecting_faces) & to_face >= intersecting_faces(nonNan_intersecting_faces));
        ith_mesh_intersecting_faces = intersecting_faces(nonNan_intersecting_faces(ith_mesh_intersections)) - from_face;
        cell_intersection_point{i, 1} = NaN(size(dist_to_intersection, 1), 3);
        cell_intersecting_faces{i, 1} = NaN(size(intersecting_faces));
        inter_point = ray_point(dist_from_intersection_index(ith_mesh_intersections), :) + ray(dist_from_intersection_index(ith_mesh_intersections), :) .* dist_to_intersection(dist_from_intersection_index(ith_mesh_intersections));
        cell_intersection_point{i}(dist_from_intersection_index(ith_mesh_intersections), :) = inter_point;
        cell_intersecting_faces{i}(dist_from_intersection_index(ith_mesh_intersections)) = ith_mesh_intersecting_faces;
        from_face = to_face;  
%         figure
%         plotmesh(cell_vertices{i}, cell_faces{i}(ith_mesh_intersecting_faces, :));
    end
end

