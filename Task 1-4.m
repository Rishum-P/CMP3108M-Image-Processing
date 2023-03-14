clear; close all;

% -----------------------Task 1: Pre-processing -----------------------
% Step-1: Loading input image
I = imread('IMG_01.jpg');

% Step-2: Coverting image to grayscale
I_gray = rgb2gray(I);

% Step-3: Rescaling image using imresize by -50% and bilinear interpolation
I_Rescaled = imresize(I_gray,0.5,'bilinear');
figure, imshow(I_Rescaled);
title('Rescaled Image (-50%)')


% Step-4: Producing histogram before enhancing. 
mi = min(min(I_Rescaled));
ma = max(max(I_Rescaled));
L = (ma - mi) + 1;

for i = 1:L
    pixel_value(i) = i - 1;
    frequency = find( I_Rescaled == pixel_value(i) );
    Nk(i) = length( frequency );
end

%Displaying the histogram
figure, bar(pixel_value,Nk,0.7);
title('Image Histogram (Pre-Enchancement)')




% Step-5: Enhancing the image before binarisation using imadjust. 

I_Rescaled_Double = 255*im2double(I_Rescaled);

mi = min(min(I_Rescaled_Double));
ma = max(max(I_Rescaled_Double));

I_Enchanced = imadjust(I_Rescaled,[mi/255; ma/255],[0; 1]);

%Displaying the enhanced image
figure, imshow(I_Enchanced);
title('Enchanced Image')



% Step-6: Histogram after enhancement
mi = min(min(I_Enchanced));
ma = max(max(I_Enchanced));

L = (ma - mi) + 1;

%Counting the pixel intensities 
for i = 1:L
    pixel_value(i) = i - 1;
    frequency = find( I_Enchanced == pixel_value(i) );
    Nk(i) = length( frequency );
end

%Displaying the histogram
figure, bar(pixel_value,Nk,0.7);
title('Image Histogram (Post-Enchancement)')



% Step-7: Image Binarisation

%Binarizing the image using adaptive thresholding. 
I_Binary = imbinarize(I_Enchanced,'adaptive','ForegroundPolarity','dark','Sensitivity',0.51);

%Displaying the Binarized image:
figure, imshow(I_Binary);
title('Binarized Image')


%----------------------- Task 2: Edge detection -----------------------
%Detecting the edge using the Sobel algorithm
I_Edge = edge(I_Enchanced,'Sobel');

%Displaying the Edge Detected image:
figure, imshow(I_Edge);
title('Edge Detected Image (Sobel)')



% ----------------------- Task 3: Simple segmentation -----------------------

%Detecting the edge using the Sobel algorithm
I_Edge_2 = edge(I_Enchanced,'sobel');

%Removing objects bigger than 7px
I_Edge_2 = bwareaopen(I_Edge_2,7);

%Creating 2 line based structural elements
se90 = strel('line',3,90);
se0 = strel('line',3,0);

%Dilating the image with those 2 elements and filling holes.
I_Seg_Dilate = imdilate(I_Edge_2,[se90 se0]);
I_Seg_Fill = imfill(I_Seg_Dilate,'holes');

I_Seg = imclearborder(I_Seg_Fill,8);

%Displaying the Segmented image:
figure, imshow(I_Seg);
title('Segmentation Image')


%----------------------- Task 4: Object Recognition -----------------------

%Creating a labelled image
L = bwlabel(I_Seg,4);

%Getting a list of each objects Circularity

stats = regionprops('table',I_Seg,'Circularity');

%Finding which objects are washers and wish are screws based on there Circularity. Labelling them based on this. 
stats_length = height(stats);
for row = 1:stats_length
   if stats{row,1} > 0.95
       L(L == row)= 12;
   else
       L(L == row)= 13;

   end
end

%Replacing label value of 12 & 13 with 1 and 2. This is just for color
%later. 12 & 13 cannot be set initally as 1 & 2 else it breaks! Has to be
%done now.

L(L==12)=1;
L(L==13)=2;

%Creating a RGB label based on the Label.
RGB_label = label2rgb(L,'prism','k','shuffle');

%Displaying the RGB label to the screen.
figure, imshow(RGB_label)
title('Labeled Image (Orange = Washer, Red = Small Screw)')