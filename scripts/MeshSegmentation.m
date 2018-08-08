function [segmented_faces] = MeshSegmentation(vertices, faces)
    segmented_faces = (zeros(size(faces, 1), 1));
    max_z = max(vertices(:,3 ));
    min_z = min(vertices(:,3));
    
    % tresholds
    length_z = max_z - min_z;
    head_tresh = max_z - 0.2 * length_z;
    tail_tresh = min_z + 0.35 * length_z;
    
    % retrieves body data splitting mesh in 3 parts by z axis
    head_faces = find(sum(ismember(faces, find(vertices(:,3) <= max_z & vertices(:,3) >= head_tresh)), 2) > 0);
    tail_faces = find(sum(ismember(faces, find(vertices(:,3) <= tail_tresh & vertices(:,3) >= min_z)), 2) > 0);
    body_faces = find(sum(ismember(faces, find(vertices(:,3) < head_tresh & vertices(:,3) > tail_tresh)), 2) > 0);

    segmented_faces(head_faces) = 1;
    segmented_faces(tail_faces) = 3;
    segmented_faces(body_faces) = 2;
end

