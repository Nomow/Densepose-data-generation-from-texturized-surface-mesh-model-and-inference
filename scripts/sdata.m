%% data load
mesh = readObj('/home/janis/Documents/Alvils/Zivis/fish_models/fish_scanned/meshnew.obj');

[bg_ims_file_path] = GetImsInFolder('/home/janis/Documents/Alvils/Zivis/matlab/bg/');
[texture_ims_file_path] = GetImsInFolder('/home/janis/Documents/Alvils/Zivis/matlab/texture/');

json_path = '/home/janis/Documents/Alvils/Zivis/matlab/data/';
json_file_name  = "data.json";
json_full_path = json_path + json_file_name;
im_path = '/home/janis/Documents/Alvils/Zivis/matlab/data/im/';
[data] = LoadJsonDataAnns(json_full_path);
    
%% mesh preprocesses - struct to var
mesh.v = mesh.v(:,1:3);
vertices = mesh.v;
faces = mesh.f.v;
vertices_uv = mesh.vt;
faces_uv = mesh.f.vt;

%% mesh segmentation in 3 parts
%[segmented_faces] = MeshSegmentation(vertices, faces);
segmented_faces = repmat(1, size(faces, 1), 1);
%% cell data

% generates mutiple meshes

max_nb_of_meshes = 2;
min_nb_of_mesh = 2;
for i = 1:20
    cell_vertices = {};
    cell_faces = {};
    cell_vertices_uv = {};
    cell_faces_uv = {};
    cell_segmented_faces = {};
    nb_of_meshes = randi([min_nb_of_mesh, max_nb_of_meshes]);
    
    for j = 1:nb_of_meshes
        cell_vertices{j, 1} = vertices;
        cell_faces{j, 1} = faces;
        cell_vertices_uv{j, 1} = vertices_uv;
        cell_faces_uv{j, 1} = faces_uv;
        cell_segmented_faces{j, 1} = segmented_faces;
        
        texture_im_index = randi([1, size(texture_ims_file_path, 1)]);
        cell_texture_im{j, 1} = imread(texture_ims_file_path{texture_im_index});
    end
    
    bg_im_index = randi([1, size(bg_ims_file_path,1)]);
    bg_im = imread(bg_ims_file_path{bg_im_index});

    %% transformation of meshes    
    if(i > 6000)
        [cell_transformed_vertices, cell_transformed_faces] = TransformMeshesOnImg(cell_vertices, cell_faces, bg_im);
    elseif(i > 4000)
        [cell_transformed_vertices, cell_transformed_faces] = TransformMeshOnImgParallel(cell_vertices, cell_faces, bg_im);
    elseif(i > 2000)
        [cell_transformed_vertices, cell_transformed_faces] = TransformMeshesOnImgInStraightLine(cell_vertices, cell_faces, bg_im);
    else 
        [cell_transformed_vertices, cell_transformed_faces] = TransformMeshOnImgOnToEachOther(cell_vertices, cell_faces, bg_im);
    end

   
%     figure
%     im_coords = combvec(1:size(bg_im, 2), 1:size(bg_im, 1))';
%     for j = 1:size(cell_transformed_vertices, 1)
%         plotmesh(cell_transformed_vertices{j}, cell_transformed_faces{j});
%         hold on
%         plot(im_coords(:,1), im_coords(:, 2), '.');
%         hold on
%     end
%     
    tic
    [bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y, im] = GenerateImAndAnns(cell_transformed_vertices, cell_transformed_faces, cell_vertices_uv, cell_faces_uv, cell_segmented_faces, cell_texture_im, bg_im);
    toc
    [data] = AddAnnsToJsonDataset(data, bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y, im);
    full_im_file_path = char(fullfile(im_path, data.images{end}.file_name));
    imwrite(im, full_im_file_path);
    disp(i)
end

full_json_file_path = fullfile(json_path, json_file_name);

fid = fopen(full_json_file_path,'w');
fprintf(fid, '%s', savejson('',data,'ArrayIndent',0));
fclose(fid);




% for j = 1:size(data.annotations, 2)
%     for k = 1:size(data.annotations{j}.segmentation, 2)
%         t = data.annotations{j}.segmentation{k};
%         onedim = size(t, 1) * size(t, 2);
%         ind = 1;
%         for l = 1:size(t, 1)
%             for m = 1:size(t, 2)
%                 onedim(ind) = t(l, m);
%                 ind = ind + 1;
%             end
%         end
%         data.annotations{j}.segmentation{k} = onedim;
%     end
% end
% 
% for i = 1:size(temp.annotations, 2)
%     if(iscell(temp.annotations{i}.segmentation))
%         to_delete = zeros(size(temp.annotations{i}.segmentation, 2), 1);
% 
%         for j = 1:size(temp.annotations{i}.segmentation, 2)
%             if(size(temp.annotations{i}.segmentation{j}, 2) < 6)
%                % temp.annotations{i}.segmentation{j} = [];
%                 to_delete(j) = 1;
%             end
%         end
%         to_del_index = find(to_delete == 1);
%         if(~isempty(to_del_index))
%             temp.annotations{i}.segmentation(to_del_index) = [];
%         end
%     else
%         if(size(temp.annotations{i}.segmentation, 2) < 6)
%                  temp.annotations{i}.segmentation = [];
%                 disp(i)
%         end    
%     end
% end
% 
% to_remove_anns = zeros(size(temp.annotations, 2), 1);
% for i = 1:size(temp.annotations, 2)
%         if(isempty(temp.annotations{i}.segmentation))
%             to_remove_anns(i) = 1;
%         end
% end
% 
% to_remove_anns_index = find(to_remove_anns == 1);
% temp.annotations(to_remove_anns_index) = [];
% 
% for i = 1:size(temp.annotations, 2)
%         if(~iscell(temp.annotations{i}.segmentation))
%             temp_data = temp.annotations{i}.segmentation;
%             temp.annotations{i}.segmentation = {};
%             temp.annotations{i}.segmentation{1} = temp_data;
%         end
% end
% 
% to_remove_anns = zeros(size(temp.annotations, 2), 1);
% for i = 1:size(temp.annotations, 2)
%         if(size(temp.annotations{i}.segmentation, 2) > 5)
%             to_remove_anns(i) = 1;
%         end
% end
% to_remove_anns_index = find(to_remove_anns == 1);
% temp.annotations(to_remove_anns_index) = [];

% 
% %% display segmentation
% imshow(im)
% hold
% for i =1:size(segmentation, 1)
%     for j =1 :size(segmentation{i}, 1)
%         plot(segmentation{i}{j}(:,1), segmentation{i}{j}(:,2), '*');
%     end
% end
% 
% %% masks display
% %imshow(im)
% temp_im = im;
% for i =1:size(dp_masks, 1)
%     mask = zeros(256, 256);
%     for j = 1:size(dp_masks, 2)
%         index = find(dp_masks{i, j} > 0)
%         mask(index) = j;
%     end
%     mask = logical(mask);
% 
%     bbr = round(bbox{i});
%     x1 = bbr(1);
%     y1 = bbr(2);
%     x2 = bbr(1) + bbr(3);
%     y2 = bbr(2) + bbr(4);
%     x2 = min([x2, size(temp_im ,2)]);
%     y2 = min([y2, size(temp_im, 1)]);
%     
%     resized_mask = imresize(mask,[x2 - x1, y2-y1], 'nearest');
%     [px, py] = find(resized_mask > 0);
%     px = x1 + px;
%     py = y1 + py;
%     hold on
%     for j = 1:size(px, 1)
%         temp_im(py(j), px(j), :) = [0,0,0];
%     endyourImage
% end
% imshow(temp_im)
% 
% %% iuv display
% imshow(im)                dp_masks(j, k)

% hold
% for i =1:size(dp_x, 1)
%     
%     bbr = bbox{i};
%     x1 = bbr(1);
%     y1 = bbr(2);
%     x2 = bbr(1) + bbr(3);
%     y2 = bbr(2) + bbr(4);
%     x2 = min([x2, size(im ,2)]);
%     y2 = min([y2, size(im, 1)]);
%     point_x = (dp_x{i}) ./ 255 .* (bbr(3));
%     point_y = (dp_y{i}) ./ 255 .* (bbr(4));
%     point_x = point_x + x1;
%     point_y = point_y + y1;
% 
%     plot(point_x, point_y, '.');
% 
% end
% 
% 
% 
