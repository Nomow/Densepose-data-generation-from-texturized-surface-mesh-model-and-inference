function [cell_intersection_point, cell_intersecting_faces, cell_transformed_vertices, cell_transformed_faces, cell_vertices_uv, cell_faces_uv, cell_texture_im, cell_segmented_faces] = RemoveNonIntersectingMeshes(cell_intersection_point, cell_intersecting_faces, cell_transformed_vertices, cell_transformed_faces, cell_vertices_uv, cell_faces_uv, cell_texture_im, cell_segmented_faces)
    % checks if mesh is in img
    EmptyCheck = @(x) find(sum(~isnan(x) == 1, 1) == 0);
    isNan = cellfun(EmptyCheck,cell_intersecting_faces, 'UniformOutput',false);    
    to_remove = find(~cellfun(@isempty,isNan));
    % removes data if no intersections
    if(~isempty(to_remove))
        cell_intersection_point(to_remove) = [];
        cell_intersecting_faces(to_remove) = [];
        cell_transformed_vertices(to_remove) = [];
        cell_transformed_faces(to_remove) = [];
        cell_vertices_uv(to_remove) = [];
        cell_faces_uv(to_remove) = [];
        cell_texture_im(to_remove) = [];;
        cell_segmented_faces(to_remove) = [];
    end
end

