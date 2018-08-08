function [data] = AddAnnsToJsonDataset(data, bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y, im)
    [data] = AddImDataToJsonDataset(data, im);
    [data] = AddAnnsDataOfImToJsonDataset(data, bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y);
end


function [data] = AddAnnsDataOfImToJsonDataset(data, bbox, segmentation, area, dp_masks, dp_i, dp_u, dp_v, dp_x, dp_y)
    for j  = 1:size(dp_i, 1)
        ann_id = 0;
        if(~isempty(data.annotations))
            ann_id = data.annotations{end}.id + 1;
        end
        im_anns = struct;
        
        % converts from [x, y]; [x1, y1] to [x, y, x1, y1....]
        segm =  cellfun(@(x) x - 1, segmentation{j}', 'UniformOutput',false);
        for k = 1:size(segm, 2)
            temp = segm{k};
            onedim = size(temp, 1) * size(temp, 2);
            ind = 1;
            for l = 1:size(temp, 1)
                for m = 1:size(temp, 2)
                    onedim(ind) = temp(l, m);
                    ind = ind + 1;
                end
            end
            segm{k} = onedim;
        end
        
        % checks if segmentation has atleast 6 points to form area
        is_valid_segment  =  zeros(size(segm, 2), 1);
        for k = 1:size(segm, 2)
            if(size(segm{k}, 2) >= 6)
                is_valid_segment(k) = 1;
            end
        end
        is_not_valid_segment_index = find(is_valid_segment == 0);
        if(~isempty(is_not_valid_segment_index))
            segm(is_not_valid_segment_index) = [];
        end
        if(size(segm, 2) > 0 && size(segm, 2) < 6)

            im_anns.segmentation = segm;
            im_anns.num_keypoints = 0;
            im_anns.area = area{j};
            im_anns.dp_I = dp_i{j, :}';
            im_anns.iscrowd = 0;
            im_anns.keypoints = [];
            im_anns.dp_x = dp_x{j, :}' - 1;
            im_anns.dp_U = dp_u{j, :}';
            im_anns.image_id = data.images{end}.id;
            im_anns.dp_V = dp_v{j, :}';
            im_anns.bbox = bbox{j, :}' - 1;
            im_anns.category_id = 1;
            im_anns.dp_y = dp_y{j, :}' - 1;
            im_anns.id = ann_id;

            im_anns.dp_masks = {}; % dp_masks(j, :);
            for k=1:size(dp_masks, 2)
                if(~isempty(find(dp_masks{j, k} > 0)))
                    im_anns.dp_masks{1, k} = MaskApi.encode(uint8(dp_masks{j, k}));
                else
                    im_anns.dp_masks{1, k} = [];
                end
            end
            data.annotations{end + 1} = im_anns;
        end
    end
end


function [data] = AddImDataToJsonDataset(data, im)
    id = 0;
    filename = string(id) + '.jpg';
    if(~isempty(data.images))
        id = data.images{end}.id + 1;
        filename = string(id) + '.jpg';
    end
    im_data = struct;
    im_data.license = 1;
    im_data.file_name = filename; %
    im_data.coco_url = '';
    im_data.coco_url = '';
    im_data.height = size(im, 1);
    im_data.width = size(im, 2);
    im_data.flickr_url = '';
    im_data.id = id; %
    data.images{end + 1} = im_data;
end
