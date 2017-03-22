function numberPlateExtraction1
% This fuction - 'numberPlateExtraction' extracts the characters from the input number plate image.
% when number plate image is closer with some part of the car if it fails
% then run numberPlateExtraction2
%% Input Image
f=imread('10.jpg');
figure(1)
subplot(231);imagesc(f);
title('original image');

%% Preprocessing
% Resizing the image keeping aspect ratio same.
f=imresize(f,[400 NaN]);

% Converting the RGB (color) image to gray (intensity).
g=rgb2gray(f);
colormap(gray)
subplot(232);imagesc(g);
title('grayscale-resized');

% Median filtering to remove noise.
g=medfilt2(g,[3 3]);

%% Morphological processing
se=strel('disk',1);
% Dilation
gi=imdilate(g,se);
gi=imdilate(gi,se);
%gi=imdilate(gi,se);
subplot(233);imagesc(gi);
title('dilated image');
% Erosion
ge=g;
%ge=imerode(ge,se);
subplot(234);imagesc(ge);
title('eroded image');

% Morphological Gradient for edges enhancement.
gdiff=imsubtract(gi,ge);
% Converting the matrix to double image.
gdiff=mat2gray(gdiff);
% Convolution of double image for brightening edges.
gdiff=conv2(gdiff,[1 1;1 1]);
% Adjust the contrast of image, specifying contrast limits. Intensity scaling between the range 0 to 1.
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1);
% Conversion from double to binary.
B=logical(gdiff);
% Here B is the final b/w image of car for extracting number plate
subplot(235);imagesc(B);
title('Subtracted image dilated-eroded');

%% For the extraction of number plate region

% Eliminating the possible horizontal lines that could be edges of license plate.
% locating horizontal lines
er=imerode(B,strel('line',50,0));
% deletiong horizontal lines from b/w image B
out1=imsubtract(B,er);
% locating vertical lines
er=imerode(out1,strel('line',50,90));
% deletiong vertical lines after deleting horizontal lines
out1=imsubtract(out1,er);
subplot(236);imagesc(out1);
title('After Eliminating Horizontal and Vertical');

% Filling all the regions of the image.
F=imfill(out1,'holes');
figure(2)
colormap('gray')
subplot(231);imagesc(out1);
title('Filling holes in Image');

% Thinning the image to ensure character isolation.
H=bwmorph(F,'thin',1);
H=imerode(H,strel('line',3,90));
subplot(232);imagesc(H);
title('Thinning image');

% Selecting all the regions that are of pixel area more than 100.
final=bwareaopen(H,100);
subplot(233);imagesc(final);
title('Final Image after eliminating smaller regions');

% Bounding boxes are acquired.
Iprops=regionprops(final,'BoundingBox','Image');

% Selecting all the bounding boxes
NR=cat(1,Iprops.BoundingBox);
figure(3)
colormap('gray')
% Calling of controlling function.
r=controlling(NR); % Function 'controlling' outputs the array of indices of boxes required for extraction of characters.
if ~isempty(r) % If succesfully indices of desired boxes are achieved.
    I={Iprops.Image}; % Cell array of 'Image' (one of the properties of regionprops)
    noPlate=[];
    for v=1:length(r)
        N=I{1,r(v)}; % Extracting the binary image corresponding to the indices in 'r'.
        subplot(2,5,v);imagesc(N);
        title(v);    
        letter=readLetter(N); % Reading the letter corresponding the binary image 'N'.
        while letter=='O' || letter=='0' % Since it wouldn't be easy to distinguish
            if v<=3                      % between '0' and 'O' during the extraction of character
                letter='O';              % in binary image. Using the characteristic of plates in Karachi
            else                         % that starting three characters are alphabets, this code will
                letter='0';              % easily decide whether it is '0' or 'O'. The condition for 'if'
            end                          % just need to be changed if the code is to be implemented with some other
            break;                       % cities plates. The condition should be changed accordingly.
        end
        noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
        if v==1
            CityCode=letter;
        end
        if v==2
            CityCode=[CityCode letter]
        end
        
        if v==5
            VehicleClass=letter
            %vehicle class codes for delhi
            if CityCode == 'DL'
                if VehicleClass == 'S'
                    VehicleClass='Two Wheeler';
                elseif VehicleClass == 'C'
                    VehicleClass='Car';
                elseif VehicleClass == 'E'
                    VehicleClass='Electric';
                elseif VehicleClass == 'P'
                    VehicleClass='Passenger';
                elseif VehicleClass == 'R'
                    VehicleClass='Rickshaw';
                elseif VehicleClass == 'V'
                    VehicleClass='Van';
                elseif VehicleClass == 'T'
                    VehicleClass='Taxi';
                end
            elseif CityCode == 'AP'
                if VehicleClass == 'S'
                    VehicleClass='Two Wheeler'
                elseif VehicleClass == 'B'
                    VehicleClass='Car'
                end
            elseif CityCode == 'RJ'
                if VehicleClass == 'S'
                    VehicleClass='Two Wheeler'
                elseif VehicleClass == 'C'
                    VehicleClass='Car'
                end
            elseif CityCode == 'HH'
                if VehicleClass == 'S'
                    VehicleClass='Two Wheeler'
                elseif VehicleClass == 'D'
                    VehicleClass='Car'
                end
            end
        end
    end
    
    clc
    fprintf('Number plate  :  %s\n',noPlate)
    
    
    
    dbfile = fullfile(pwd,'SmartPark.db');
    %creating table vehicleRecords
    conn = sqlite(dbfile,'create');
    createVehicleRecordsTable = ['create table VehicleRecords (VehicleNumber VARCHAR, VehicleClass VARCHAR, CheckInYear NUMERIC, CheckInMonth NUMERIC, CheckInDay NUMERIC, CheckInHour NUMERIC, CheckInMinute NUMERIC, CheckOutYear NUMERIC, CheckOutMonth NUMERIC, CheckOutDay NUMERIC, CheckOutHour NUMERIC, CheckOutMinute NUMERIC, Amount NUMERIC)'];
    exec(conn,createVehicleRecordsTable)
    close(conn)
    
    %inserting VehicleRecords
    InOut='In'
    a = clock;
    if InOut=='In'
        %insert into table- checkIn details
        conn = sqlite(dbfile);
        VehicleData = {noPlate,VehicleClass,a(1),a(2),a(3),a(4),a(5)} ;
        insert(conn,'VehicleRecords',{'VehicleNumber','VehicleClass','CheckInYear','CheckInMonth','CheckInDay','CheckInHour','CheckInMinute'},VehicleData)
        close(conn)
        
    elseif InOut=='Out'
        %insert into table- CheckOut details
        conn = sqlite(dbfile);
        %assumption same day checkIn and CheckOut
        if VehicleClass == 'Two Wheeler'
            %amt = (((checkouthour-checkinhour)*60+(checkoutMin-checkInMin))/60)*5+10 
        elseif VehicleClass == 'Car'
        %amt = (((checkouthour-checkinhour)*60+(checkoutMin-checkInMin))/60)*5+10 
        VehicleData = {noPlate,VehicleClass,a(1),a(2),a(3),a(4),a(5),0} ;
        insert(conn,'VehicleRecords',{'VehicleNumber','VehicleClass','CheckOutYear','CheckOutMonth','CheckOutDay','CheckOutHour','CheckOutMinute','Amount'},VehicleData)
        close(conn)
    end
    
    %fetching all vehicle records
    conn = sqlite(dbfile);
    Vehicle_data = fetch(conn,'SELECT * FROM VehicleRecords');
    Vehicle_data
    close(conn)
    
else
    % If fail to extract the indexes in 'r' this line of error will be displayed.
    numberPlateExtraction2()
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end
end