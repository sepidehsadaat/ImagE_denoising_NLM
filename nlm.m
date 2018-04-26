% NL-means algorithm
clc;clear;
image = im2double(imread('lena.jpg'));
% img = img(820:1220,720:1120);
image = imresize(image,[512,512]);
image_size = size(image);
figure(1);
imshow(image);
title('original image');

% parameters initiliazation 
L = 9;
h = 0.15;
nlock_size = 2;
window_size = 10;
sigma = 25;
%noise image creation
noisy_img = imnoise(image,'gaussian', 0, 0.004);
psnr_noise=psnr(noisy_img,image) 
figure(2);
imshow(noisy_img);
title('noisy image');
%%
%%% NLM

G = fspecial('gaussian',nlock_size*2+1,1);
result = zeros(image_size);
 % gourping ismilar blocks in a search window
for ch = 1:3
for i = nlock_size+1:image_size(1)-nlock_size
    i
    for j = nlock_size+1:image_size(2)-nlock_size
        z = 0;
        noisy_img_ch=noisy_img(:,:,ch);
        weight = zeros(image_size(1), image_size(2));
        for k = max(i-window_size,nlock_size+1):min(i+window_size,image_size-nlock_size)
            for l = max(j-window_size,nlock_size+1):min(j+window_size,image_size-nlock_size)
                if(k==i && l==j)
                    continue
                end
                tmp = noisy_img_ch(i-nlock_size:i+nlock_size,j-nlock_size:j+nlock_size)-noisy_img_ch(k-nlock_size:k+nlock_size,l-nlock_size:l+nlock_size);
                tmp = tmp.*tmp;
                tmp = tmp.*G;
                weight(k,l) = exp(-sum(tmp(:))/(h*h));
                z = z + weight(k,l);
            end
        end
        %weight normalization 
        weight = weight/z;
        for k = max(i-window_size,nlock_size+1):min(i+window_size,image_size-nlock_size)
            for l = max(j-window_size,nlock_size+1):min(j+window_size,image_size-nlock_size)
                result(i,j,ch) = result(i,j,ch) + weight(k,l)*noisy_img_ch(k,l);
            end
        end
    end
end
end
%psnr claculation
psnr_=psnr(result,image)
figure(3);
imshow(result)