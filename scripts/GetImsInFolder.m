function [full_path] = GetImsInFolder(directory_path, file_name)
    if(nargin == 1)
        files =  dir(directory_path);
        file_name = {files.name}';
        file_name(1:2) = [];
        for i = 1:size(file_name,1)
            full_path{i} = fullfile(directory_path, file_name{i});
        end
        full_path = full_path';
    else
        full_path{1} = fullfile(directory_path, file_name);
    end
end

