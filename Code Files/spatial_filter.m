function filtered_img = spatial_filter(img, kernel)
    [img_height, img_width] = size(img);
    [kernel_height, kernel_width] = size(kernel);
    pad_height = floor(kernel_height / 2);
    pad_width = floor(kernel_width / 2);
    padded_img = padarray(img, [pad_height, pad_width]);
    filtered_img = zeros(size(img));
    for i = 1:img_height
        for j = 1:img_width
            region = padded_img(i:i+kernel_height-1, j:j+kernel_width-1);
            filtered_img(i, j) = sum(sum(double(region) .* kernel));
        end
    end
end