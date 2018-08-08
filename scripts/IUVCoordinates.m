function [dp_i, dp_u, dp_v] = IUVCoordinates(cell_vertices, cell_faces, cell_vertices_uv, cell_faces_uv, cell_intersection_pts,  cell_intersection_faces, cell_mesh_segments)
    u{size(cell_vertices, 1),1} = [];
    v{size(cell_vertices, 1),1} = [];
    w{size(cell_vertices, 1),1} = [];
    dp_i{size(cell_vertices, 1),1} = [];
    dp_u{size(cell_vertices, 1),1} = [];
    dp_v{size(cell_vertices, 1),1} = [];

    for i = 1:size(cell_vertices, 1)
        % finds barycentric coordinates of intersections, to calculate UV
        % cordinates
        vertices = cell_vertices{i};
        faces = cell_faces{i};
        intersection_pts = cell_intersection_pts{i}(find(sum(~isnan(cell_intersection_pts{i}), 2) > 0), :);
        intersection_faces = cell_intersection_faces{i}(find(~isnan(cell_intersection_faces{i})), :);

        a = vertices(faces(intersection_faces, 1), :);
        b = vertices(faces(intersection_faces, 2), :);
        c = vertices(faces(intersection_faces, 3), :);
        [u{i}, v{i}, w{i}] = BarycentricCoordinates(intersection_pts, a, b, c);
        
        %% calculates iuv coordinates
        vertices_uv = cell_vertices_uv{i};
        faces_uv = cell_faces_uv{i};
        auv = vertices_uv(faces_uv(intersection_faces, 1), :);
        buv = vertices_uv(faces_uv(intersection_faces, 2), :);
        cuv = vertices_uv(faces_uv(intersection_faces, 3), :);
        puv = u{i} .* auv + v{i} .* buv + w{i} .* cuv;
        
        dp_i{i} = cell_mesh_segments{i}(intersection_faces);
        dp_u{i} = puv(:,1);
        dp_v{i} = puv(:,2);
    end
    
end

