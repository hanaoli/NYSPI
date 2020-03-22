function createROItxt(image_filename, ROI_filename, weight)
    % load img and roi data
    img = spm_read_vols(spm_vol(image_filename));
    roi = spm_read_vols(spm_vol(ROI_filename));

    idx = find(roi > 0); % find index larger than 0
    [roi_index_x, roi_index_y, roi_index_z] = ind2sub(size(roi), idx); % Get x,y,z corrdinate 
    roi_voxelNum=length(roi_index_x); % find voxelnumber

    if length(weight) < 1
        weight = ones(roi_voxelNum, 1); % initialize weight
    end    
    intensity = ones(roi_voxelNum, 1); % initialize intensity

    % Get intensity values
    for i = 1:roi_voxelNum
        intensity(i) = img(roi_index_x(i), roi_index_y(i), roi_index_z(i));
    end

    % add 0 to the last row
    roi_index_x = [roi_index_x; 0];
    roi_index_y = [roi_index_y; 0];
    roi_index_z = [roi_index_z; 0];
    weight = [weight; 0];
    intensity = [intensity; 0];
    [x, y, z] = size(img); % get dimension information

    fileID = fopen('C:/Users/36576/Desktop/SPM/roi.txt', 'w');
    fprintf(fileID, '%d %1d %1d\n', [x,y,z]);
    fprintf(fileID, '%d\n', roi_voxelNum);
    fprintf(fileID, '%d %1d %1d %6.6f %6.6f\n', [roi_index_x, roi_index_y, roi_index_z, weight, intensity].');
    fclose(fileID);
end

