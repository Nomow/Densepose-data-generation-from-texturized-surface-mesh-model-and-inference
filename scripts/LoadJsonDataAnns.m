% loads or creates json dataset
function [data] = LoadJsonDataAnns(file_path)
    data = struct;
    if (exist(file_path, 'file'))
        data = loadjson(file_path);
        % converts segments to cell array in case there is only 1
        % segmentation
        for i = 1:size(data.annotations, 2)
            if(~iscell(data.annotations{i}.segmentation))
                temp_data = data.annotations{i}.segmentation;
                data.annotations{i}.segmentation = {};
                data.annotations{i}.segmentation{1} = temp_data;
            end
        end
    else
        data = struct;
        data.images = {};
        data.annotations = {};
        data.categories = {};
        categories = struct;
        categories.supercategory = 'fish';
        categories.id = 1;
        categories.keypoints = {};
        categories.name = 'fish';
        categories.skeleton =  {};
        data.categories{end + 1} = categories;
    end
    
end

