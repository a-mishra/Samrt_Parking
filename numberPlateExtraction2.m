function [noPlate,VehicleClass,Amount] = numberPlateExtraction2(img,InOut)
% This fuction - 'numberPlateExtraction' extracts the characters from the input number plate image.
% when number plate image is closer with some part of the car if it fails
% then run numberPlateExtraction2
%% Input Image
%f=imread('11.jpg');
f=img;
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
%gi=g;
gi=imdilate(g,se);
%gi=imdilate(gi,se);
subplot(233);imagesc(gi);
title('dilated image');
% Erosion
%ge=g;
ge=imerode(g,se);
subplot(234);imagesc(ge);
title('eroded image');

% Morphological Gradient for edges enhancement.
gdiff=imsubtract(gi,ge);
% Converting the matrix to double image.
gdiff=mat2gray(gdiff);
% Convolution of double image for brightening edges.
gdiff=conv2(gdiff,[1 1;1 1]);
% Adjust the contrast of image, specifying contrast limits. Intensity scaling between the range 0 to 1.
gdiff=imadjust(gdiff,[0.6 0.7],[0 1],0.2);
% Conversion from double to binary.
B=logical(gdiff);
% Here B is the final b/w image of car for extracting number plate
subplot(235);imagesc(B);
title('Subtracted image dilated-eroded');

%% For the extraction of number plate region

% Eliminating the possible horizontal lines that could be edges of license plate.
% locating horizontal lines
er=imerode(B,strel('line',15,0));
% deletiong horizontal lines from b/w image B
out1=imsubtract(B,er);
% locating vertical lines
er=imerode(out1,strel('line',40,90));
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
H=imerode(H,strel('line',2,90));
subplot(232);imagesc(H);
title('Thinning image');

% Selecting all the regions that are of pixel area more than 100.
final=bwareaopen(H,180);
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
    flag=0;
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
        
        
        
        if (isletter(letter) && v>2 && flag==0)
            VehicleClass=letter
            flag=1;
            %vehicle class codes for delhi
            if CityCode == 'DL'
                if VehicleClass == 'S'
                    VehicleClass='TWL';
                elseif VehicleClass == 'C'
                    VehicleClass='CAR';
                elseif VehicleClass == 'E'
                    VehicleClass='ELE';
                elseif VehicleClass == 'P'
                    VehicleClass='PAS';
                elseif VehicleClass == 'R'
                    VehicleClass='RCK';
                elseif VehicleClass == 'V'
                    VehicleClass='VAN';
                elseif VehicleClass == 'T'
                    VehicleClass='TAX';
                end
            elseif CityCode == 'AP'
                if VehicleClass == 'S'
                    VehicleClass='TWL'
                elseif VehicleClass == 'B'
                    VehicleClass='CAR'
                end
            elseif CityCode == 'RJ'
                if VehicleClass == 'S'
                    VehicleClass='TWL'
                elseif VehicleClass == 'C'
                    VehicleClass='CAR'
                end
            elseif CityCode == 'HH'
                if VehicleClass == 'S'
                    VehicleClass='TWL'
                elseif VehicleClass == 'D'
                    VehicleClass='CAR'
                end
            else VehicleClass='CAR'
            end
        end
    end
    
    clc
    fprintf('Number plate  :  %s\n',noPlate)
    
    
    
    dbfile = fullfile(pwd,'SmartPark.db');
%     creating table vehicleRecords
%     conn = sqlite(dbfile,'create');
%     createVehicleRecordsTable = ['create table VehicleRecords (VehicleNumber VARCHAR, VehicleClass VARCHAR, CheckInYear NUMERIC, CheckInMonth NUMERIC, CheckInDay NUMERIC, CheckInHour NUMERIC, CheckInMinute NUMERIC, CheckOutYear NUMERIC, CheckOutMonth NUMERIC, CheckOutDay NUMERIC, CheckOutHour NUMERIC, CheckOutMinute NUMERIC, Amount NUMERIC)'];
%     exec(conn,createVehicleRecordsTable)
%     close(conn)

%     conn = sqlite(dbfile,'create');
%     createHistoryTable = ['create table History (VehicleNumber VARCHAR, VehicleClass VARCHAR, CheckInYear NUMERIC, CheckInMonth NUMERIC, CheckInDay NUMERIC, CheckInHour NUMERIC, CheckInMinute NUMERIC, CheckOutYear NUMERIC, CheckOutMonth NUMERIC, CheckOutDay NUMERIC, CheckOutHour NUMERIC, CheckOutMinute NUMERIC, Amount NUMERIC)'];
%     exec(conn,createHistoryTable)
%     createCurrentTable = ['create table Current (VehicleNumber VARCHAR, VehicleClass VARCHAR, CheckInYear NUMERIC, CheckInMonth NUMERIC, CheckInDay NUMERIC, CheckInHour NUMERIC, CheckInMinute NUMERIC, Amount NUMERIC)'];
%     exec(conn,createCurrentTable)
%     close(conn)


    a = clock;
    fix(a);
    if (InOut=='In')
        conn = sqlite(dbfile);
        if(VehicleClass == 'TWL')
            Amount = 10
        elseif(VehicleClass=='CAR')
            Amount = 20
        else Amount = 20
        end
        VehicleData = {noPlate,VehicleClass,a(1),a(2),a(3),a(4),a(5),Amount} ;
        insert(conn,'Current',{'VehicleNumber','VehicleClass','CheckInYear','CheckInMonth','CheckInDay','CheckInHour','CheckInMinute','Amount'},VehicleData)
        close(conn)
        
    elseif (InOut=='Ot')
        conn = sqlite(dbfile);
        VehicleDataAll = fetch(conn,'SELECT * FROM Current');
        s = size(VehicleDataAll);
        for i=s(1):-1:1
            if(cell2mat(VehicleDataAll(i)) == noPlate)
                VehicleDatax = VehicleDataAll(i);
                for j=2:1:8
                    VehicleDatax = [VehicleDatax VehicleDataAll(i,j)];
                end
            break   
            end
            if(i == 1)
                %popup car not found in current table
                msgbox('!!! Car not found in Current table !!!','Error')
            end
        end
        
        
        VehicleData2 = cell2mat(VehicleDatax(3))
        for j=4:1:8
                    VehicleData2 = [VehicleData2 cell2mat(VehicleDatax(j))] 
        end
        VehicleData2;
        Amount = VehicleData2(8-2)
        t2 = [double(VehicleData2(3-2)),double(VehicleData2(4-2)),double(VehicleData2(5-2)),double(VehicleData2(6-2)),double(VehicleData2(7-2)),double(0)]
        Amount = Amount+((etime(a,t2))/60)*1
        VehicleData3 = {noPlate',VehicleClass,VehicleData2(3-2),VehicleData2(4-2),VehicleData2(5-2),VehicleData2(6-2),VehicleData2(7-2),a(1),a(2),a(3),a(4),a(5),Amount} ;
        insert(conn,'History',{'VehicleNumber','VehicleClass','CheckOutYear','CheckInYear','CheckInMonth','CheckInDay','CheckInHour','CheckInMinute','CheckOutMonth','CheckOutDay','CheckOutHour','CheckOutMinute','Amount'},VehicleData3)
        close(conn)
    end
    
else
    % If fail to extract the indexes in 'r' this line of error will be displayed.
    %numberPlateExtraction2()
    msgbox('!!! Unable to extract the characters from the number plate !!!','Error')
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
    noPlate = '0';
    class = '0';
end
end