function [bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y, im] = GenerateImAndAnns(cell_vertices, cell_faces, cell_vertices_uv, cell_faces_uv, cell_segmented_faces, cell_texture_im, bg_im)


    bg_im =  permute((bg_im), [2, 1, 3]);
    for i = 1:size(cell_texture_im, 1)
        cell_texture_im{i} = permute((cell_texture_im{i}), [2, 1, 3]);
    end
    
    %% intersects Img with meshes
    [cell_intersection_point, cell_intersecting_faces] = ImgIntersectionWithMeshes(cell_vertices, cell_faces, bg_im);

    %%
    [cell_intersection_point, cell_intersecting_faces, cell_vertices, cell_faces, cell_vertices_uv, cell_faces_uv, cell_texture_im, cell_segmented_faces] = RemoveNonIntersectingMeshes(cell_intersection_point, cell_intersecting_faces, cell_vertices, cell_faces, cell_vertices_uv, cell_faces_uv, cell_texture_im, cell_segmented_faces);
    im_coords = combvec(1:size(bg_im, 1), 1:size(bg_im, 2))';
%     figure
%     for i = 1:size(cell_vertices, 1)
%        % notnan = find(~isnan(cell_intersecting_faces{i}));
%         hold on
%         plotmesh(cell_vertices{i}, cell_faces{i});
%        % hold on
%        % plot3(cell_intersection_point{i}(notnan,1), cell_intersection_point{i}(notnan,2), cell_intersection_point{i}(notnan,3), '.');
%     end
    
    
    if(size(cell_intersection_point, 1) ~= 0)
        %% calculates bbox for each mesh
        [bbox] = CalculateBbox(cell_intersecting_faces, bg_im);

        %% segmentation
        [segmentation, area] = MeshesSegmentation(cell_intersecting_faces, bg_im);

        %%  segmenteded image in densepose form
        dp_bbox_width = 256;
        dp_bbox_height = 256;
        [dp_masks] = MaskIm(cell_segmented_faces ,cell_intersecting_faces, bbox, bg_im, dp_bbox_width, dp_bbox_height);

        %% IUV coordinates
        [dp_i, dp_u, dp_v] = IUVCoordinates(cell_vertices, cell_faces, cell_vertices_uv, cell_faces_uv, cell_intersection_point,  cell_intersecting_faces, cell_segmented_faces);

        %% dp_x dp_y coordinates
        [dp_x, dp_y] = IUVCorrespondingXYCoordinates(cell_intersection_point, bbox, dp_bbox_width, dp_bbox_height, bg_im);

        [projected_mesh_im] = MeshesToImg(bg_im, cell_texture_im, dp_u, dp_v, cell_intersecting_faces);
        im = permute((projected_mesh_im), [2, 1, 3]);
        
        % downsample coordinates
        [dp_x, dp_y, dp_i, dp_u, dp_v] = DownsamplePointClouds(dp_x, dp_y, dp_i, dp_u, dp_v);
    end
end

