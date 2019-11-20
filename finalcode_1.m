% A very simple baseline Matlab program for retinal vessel detection/ segmentation coded by Jiang Xudong
close all;
% x = imread('24_training.tif'); %load the color image %read image
 x = imread('14_test.tif');
subplot(2,3,1); %???255 ???0

figure(1); 
imshow(x); %display the color image
title('figure(1)');

% subplot(2,3,2);figure(2); imshow(x(:,:,1)); %display one channel the color image
% subplot(2,3,3);figure(3); imshow(x(:,:,2)); %display one channel the color image
% subplot(2,3,4);figure(4); imshow(x(:,:,3)); %display one channel the color image
% xs = rgb2gray(x); %convert the color image into gray image
% figure(5); imshow(xs);
xg = x(:,:,2); %decide to work on green channel image %?focus on 1?channel
subplot(2,3,5);
%figure(5);  
imshow(xg);
title('figure(5)');

%Segment the image area
xt = xg;
m1 = mean(mean(xt));  
xt(find(xt>m1)) = m1;%trancate all xt value above m1 to m1 

subplot(2,3,6);
figure(6); imshow(xt, []);
title('figure(6)'); 

%segment the background mask
m2 = mean(mean(xt));
xt(find(xt>m2)) = m2;
%figure(7); 
figure(7);
imshow(xt, []);
title('figure 7');
m3 = mean(mean(xt));
xt(find(xt<m3)) = 0; 
xt(find(xt>=m3)) = 1;

figure(8);
imshow(xt, []);
title('figure(8)');

%perform erosion to remove the branch but leave the noise
se3 = strel('disk',4);             
xmask = imerode(xt,se3);
figure(9);
imshow(xmask, []);
title('figure(9)');

n = sum(sum(xt)); %number of pixel of retina image within the circle
%Segment the vessel
xin = xg.*xmask;  %original image within circle = 1
xout = xin; 

m1 = sum(sum(xout))/n; %mean of image within circle ???m1
xout(find(xout>m1)) = m1; xb=xout;
figure(10); imshow(xout, []);title('rough image');
 
for i=0:360
    B = strel('line',10,i);
    D = imdilate(xout, B);
end

D=medfilt2(D);
figure(99); imshow(D, []);title('dilate1');

xout=(D-xout)*5; %image minus noise
figure(100); imshow(xout, []);title('dif');

xedge = edge(xout,'Canny',0.9);xa=uint8(xedge); %get edge but this is not used in this project
% figure(10); imshow(xedge, []);title('xedge');

xout=xout.*xmask; %delete the edge and background
figure(11); imshow(xout, []);title('substract');

xout=medfilt2(xout);
figure(21); imshow(xout, []);title('median filter');

xout=im2bw(xout,0.12); %convert to binary image
xout=uint8(xout);
xout=xout*255;
% xout=[xout.*i5];
imwrite(xout,'14_trainingmap.tif','tiff');
figure(17);imshow(xout,[]);
imwrite(xout,'24_trainingmap.tif','tiff');

%load the vessel ground truth
truth = imread('24_manual1.gif');
figure(18);
imshow(truth, []);
title('figure(13)');
%Evaluate the segmentation accuracy %?????
[h,w] = size(xout);
tst = zeros(h,w);
tst(find(xout==truth))=1; %???coordinate ????

figure(19);
imshow(tst, []);
title('differences');
accuracy = 100*sum(sum(tst))/(h*w) 
