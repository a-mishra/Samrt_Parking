function [tps, NoOfVacantSpot, nearestParkingSpot]=calcspot(cam)
%%% Button Processed
% camputes image from selected camera and processes it to find parked and
% vacant slots
load('slots.mat');
switch cam
    case 3
        try
            vid = ipcam(camurl3);
            bck_image = double(imread('refcam3.jpg'));
            bck_img = bck_image(:,:,1);
            nodes = load('slots.mat', 'corcam3');
            nodes = nodes.corcam3;
            tps=size(nodes);
            tps=tps(1);
            
        catch E
            msgbox({'Configure The Cam Correctly!',' ',E.message},'CAM INFO')
        end

     case 4
        try
            vid = ipcam(camurl4);
            bck_image = double(imread('refcam4.jpg'));
            bck_img = bck_image(:,:,1);
            nodes = load('slots.mat', 'corcam4');
            nodes = nodes.corcam4;
            tps=size(nodes);
            tps=tps(1);
            
        catch E
            msgbox({'Configure The Cam Correctly!',' ',E.message},'CAM INFO')
        end
end

%% from raw color image to binary image with highlighted occupied spots
himage2 = snapshot(vid);
num3 = load('slots.mat', 'thres');num3 = str2double(num3.thres);          %threshold
num4 = load('slots.mat', 'eliminate');num4= str2double(num4.eliminate);   %bwareopen
hsize = load('slots.mat', 'hsize');hsize= str2double(hsize.hsize);        %gaussian filter
sigma = load('slots.mat', 'sigma');sigma=str2double(sigma.sigma);
gaus_filt = fspecial('gaussian',hsize , sigma);

img_tmp = double(himage2);                                    %load image and convert to double for computation
img2 = img_tmp(:,:,1);                                        %reduce to just the first dimension
sub_img = (img2 - bck_img);                                   %subtract background from the image
gaus_img = filter2(gaus_filt,sub_img,'same');                 %gaussian blurr the image
thres_img = (gaus_img < num3);
thres_img = ~thres_img;
thres_img = bwareaopen(thres_img,num4);
thres_img = ~thres_img;
se2 = strel('disk',1);
thres_img = imerode(thres_img,se2);

%% counting no of blobs
thres_img = ~thres_img;
[L, num] = bwlabel(thres_img);
stats = regionprops(L, 'Centroid');
thres_img = ~thres_img;

%% highlight strange objects
img3 = himage2;
% circle parameters
r = 15;                                                                    % radius
t = linspace(0, 2*pi, 20);                                                 % approximate circle with 50 points

%% highlight Occupied and Unoccupied slots
num2 = 0;
slotStatus = zeros(tps,1);
for k=1:1:tps
    c = [nodes(k,1) nodes(k,2)];                   % center
    BW = poly2mask(r*cos(t)+c(1), r*sin(t)+c(2), size(img,1), size(img,2));% create a circular mask
    if thres_img(nodes(k,2), nodes(k,1))== 0
        clr = [255 0 0 ];            % Red color for circle
        num2 = num2 + 1;             % counting no of filled spots
        slotStatus(k,1)=1; 
    else
        clr = [0 255 0 ];            % Green color for circle
        slotStatus(k,1)=0;
    end
    a = 0.8;                         % blending factor
    z = false(size(BW));
    mask = cat(3,BW,z,z); img3(mask) = a*clr(1) + (1-a)*img3(mask);
    mask = cat(3,z,BW,z); img3(mask) = a*clr(2) + (1-a)*img3(mask);
    mask = cat(3,z,z,BW); img3(mask) = a*clr(3) + (1-a)*img3(mask);
end
%% Results

%tps
for i=1:tps
if(slotStatus(i,1)==0)
    nearestParkingSpot=i;
    break
end
end
    NoOfVacantSpot = tps-num2;

end      