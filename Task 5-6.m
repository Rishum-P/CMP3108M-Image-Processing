%Setting array's containing the names of each images for both the input
%images + ground truth values
Input_Images = ["IMG_01.jpg","IMG_02.jpg","IMG_03.jpg","IMG_04.jpg","IMG_05.jpg","IMG_06.jpg","IMG_07.jpg","IMG_08.jpg","IMG_09.jpg","IMG_10.jpg"];
GT_Images = ["IMG_01_GT.png","IMG_02_GT.png","IMG_03_GT.png","IMG_04_GT.png","IMG_05_GT.png","IMG_06_GT.png","IMG_07_GT.png","IMG_08_GT.png","IMG_09_GT.png","IMG_10_GT.png"];

%Setting varables that will be used to calculate the total Dice Score
%Precision & Recall for all images.
Dice_Score_Count = 0;
Precision_Score_Count = 0;
Recall_Score_Count = 0;

%Looping 10 times as there are 10 images
for imagenum = 1:10
    
%-------------------------- Task 5: Robust method --------------------------

%Reading the image into the enviroment.
I = imread(Input_Images(imagenum));

%Converting image to greyscale
I_gray = rgb2gray(I);

%Rescaling image using imresize by -50% and bilinear interpolation
I_Rescaled = imresize(I_gray,0.5,'bicubic');

%Sharpening image with imsharpen with a radius of 2 and an amount of 9
I_Sharpened = imsharpen(I_Rescaled,'Radius',2,'Amount',9);

%Binarizing the image using adaptive thresholding. 
I_Binary = imbinarize(I_Sharpened,'adaptive','ForegroundPolarity','dark','Sensitivity',0.38);

%Using imcomplement to flip white/black.
I_Complement = imcomplement(I_Binary);

%Creating 2 line based structural elements
se90 = strel('line',2,90);
se0 = strel('line',2,0);

%Dilating the image with those 2 elements and filling holes.
I_Dilate = imdilate(I_Complement,[se90 se0]);
I_Fill = imfill(I_Dilate,'holes');

%Removing objects below 60px
I_Seg = bwareaopen(I_Fill,60);

%Creating a labelled image
L = bwlabel(I_Seg,8);

%Getting a list of each objects Circularity & Area
stats = regionprops('table',I_Seg,'Area','Circularity');

%Finding which objects are washers, large screws or small screws based on there Circularity and area.. Labelling them based on this. 
stats_length = height(stats);
for row = 1:stats_length
   if stats{row,2} > 0.75
       L(L == row)= 55;
   elseif stats{row,1} > 1000
       L(L == row)= 56;
   else 
       L(L == row)= 57;
   end
end  


%Replacing label value of 55,56 and 57 with 1,2 and 3. This is just for color
%later. They cannot be set initally as 1,2 or 3 else it breaks! Has to be
%done now.
L(L==55)=1;
L(L==56)=2;
L(L==57)=3;

%Saving the RGB label to the output folder.
RGB_label = label2rgb(L,'prism','k','shuffle'); 
name = "output/" + Input_Images(imagenum);
imwrite(RGB_label,name);



%-------------------------- Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data
GT = imread(GT_Images(imagenum));
GT = double(GT);

%Calculating the True Positives/Negatives & False Positives/Negatives. If
%statements could be shortened however it is more readable like this.
[k,y] = size(L);
True_Positive = 0;
True_Negative = 0;
False_Positive = 0;
False_Negative = 0;
missing = 0;
for a=1:k
    for b=1:y
        if (GT(a,b) == 1) && (L(a,b) == 1)
            True_Positive = True_Positive + 1;
        elseif (GT(a,b) == 2) && (L(a,b) == 2)
            True_Positive = True_Positive + 1;
        elseif (GT(a,b) == 3) && (L(a,b) == 3)
            True_Positive = True_Positive + 1; 
        elseif (GT(a,b) == 0) && (L(a,b) == 0)
            True_Negative = True_Negative + 1;
        elseif (GT(a,b) == 0) && (L(a,b) == 1)
            False_Positive = False_Positive + 1;
        elseif (GT(a,b) == 0) && (L(a,b) == 2)
            False_Positive = False_Positive + 1;
        elseif (GT(a,b) == 0) && (L(a,b) == 3)
            False_Positive = False_Positive + 1;
        elseif (GT(a,b) == 1) && (L(a,b) == 0)
            False_Negative = False_Negative + 1;
        elseif (GT(a,b) == 2) && (L(a,b) == 0)
            False_Negative = False_Negative + 1;    
        elseif (GT(a,b) == 4) && (L(a,b) == 0)
            False_Negative = False_Negative + 1;
        elseif (GT(a,b) == 2) && (L(a,b) == 3)
            False_Positive = False_Positive + 1;
        end
    end   
end


%Generating a RGB label
L_GT = label2rgb(GT, 'prism','k','shuffle');

%Converting RGB labels to Logical
GroundTruthLogical=logical(L_GT);
RGBLogical=logical(RGB_label);

%Calculating the Dice Score, Precision and Recall of the current image
Dice_Score = dice(RGBLogical,GroundTruthLogical);
Precision = True_Positive / (True_Positive + False_Positive);
Recall = True_Positive / (True_Positive + False_Negative);

%Adding the above to a running count to calculate the overall scores for
%the whole dataset.
Dice_Score_Count = Dice_Score_Count + Dice_Score;
Precision_Score_Count = Precision_Score_Count + Precision;
Recall_Score_Count = Recall_Score_Count + Recall;

%Displaying the dice score, precision and recall for the current image.
disp(" ");
disp("Image " + imagenum + ": ");

disp("Dice Score: " + Dice_Score);
disp("Precision: " + Precision);
disp("Recall: " + Recall);

%End of the loop
end

%Displaying the dice score, precision and recall for the whole dataset
disp(" ");
disp("Overall Scores:");

disp("Dice Score: " + Dice_Score_Count / 10);
disp("Precision: " + Precision_Score_Count / 10);
disp("Recall: " + Recall_Score_Count / 10);