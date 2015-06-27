clear all;
clc; % Clearing Matlab desktop
vid=videoinput('winvideo',2,'YUY2_640x480'); % Defining the video input object
set(vid,'FramesPerTrigger',1);
set(vid, 'ReturnedColorspace', 'rgb'); % Setting frames per trigger
preview(vid); %Showing the video of the moving Ball
pause(5); % Waiting for a certain time for the system to get initialised
rgb_image = getsnapshot(vid); % Storing Image in an array variable
[a b c]= size(rgb_image); % Determining the size of the captured frame.
y=a;
x=b;
% Defining Boundaries
x1=x/2-120;
x2=x/2+120;
y1=y/2-30;
y2=y/2+30;
 ser=serial('COM3'); % Defining the specified COM Port to be used
 pause(5);
 fopen(ser); % starting serial Communication, opening serial port
while(1)
    pause(1);
    image = getsnapshot(vid); % storing image in an array variable
    flushdata(vid); %Flushing the buffer
    rbar=0;
    cbar=0;
    e=0;
    k=imsubtract(image(:,:,1),rgb2gray(image));
    diff_im = medfilt2(k, [3 3]); %Use a median filter to filter out noise
    % Convert the resulting grayscale image into a binary image.
     diff_im = im2bw(diff_im,0.18);%if illumination level>0.18 ==>1, otherwise..

    diff_im = bwareaopen(diff_im,300); % Remove all those pixels less than 300px
     % Label all the connected components in the image.
     I = bwlabel(diff_im, 8);% 4 or 8 connectivity

    % Following are the steps For Detecting the red ball
    se=strel('disk',5);%structuring element, shape=disk, radius=5
    B=imopen(I,se); %morphological open operation erosion followed by dilation
    final=imclose(B,se); %morphological close operation dilation followed by erosion
    [L,n]=bwlabel(final);
    imshow(L);
    for k=1:n
        [r,c]=find(L==k);
        rbar=mean(r);
        cbar=mean(c);
        % Converting to decimal number
        e=(((cbar>=x1)*2*2*2) + ((cbar<=x2)*2*2) + ((rbar>=y1)*2) + (rbar<=y2));
        end
        % Decision Making Conditions
        switch (e)
        case 5
        disp('Move left');
        fwrite(ser,'L');
        case 6
        disp('Move left');
        fwrite(ser,'L');
        case 7
        disp('Move left');
        fwrite(ser,'L');
        case 9
        disp('Move right');
        fwrite(ser,'R');
        case 10
        disp('Move right');
        fwrite(ser,'R');
        case 11
        disp('Move right');
        fwrite(ser,'R');
        case 13
        disp('Move forward');
        fwrite(ser,'F');
        case 14
        disp('Move back');
        fwrite(ser,'B');
        otherwise
        disp('Stop Moving');
        fwrite(ser,'S');
    end
end
fclose(ser); % closing
delete(ser); %delete object file
clear ser; % clearing s matrix from the workspace