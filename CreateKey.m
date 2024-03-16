% Step 1: Creating a key
%
% This script calls several functions that you will write, using them to
% create a key image, which can be used to "lock" up a message (or unlock it)
% The size of the key to create is determined by the size of the message 
% image(s) that need to be encrypted.
%
% For this script to work you will need to write the following functions:
% CreatePatterns, GenerateKey, PatternsToImage, EmbedImage
%


r = input('Enter the number of rows in your message image:');
c = input('Enter the number of columns in your message image:');

% Generate a random number from 1 to 6 for each element in the key
randomArray = randi(6,r,c);

% Generate six 2x2 patterns storing them in a 1D 1x6 cell array
p = CreatePatterns(); % You will write this function

% Create a cell array of patterns to act as key, by converting each random
% number to the associated 2x2 pattern
key = GenerateKey(randomArray,p); % You will write this function

% Convert they key from a cell array to a grayscale image 
% i.e. a 2D array of uint8 values, so that it can saved to a file
keyImage = PatternsToImage(key); % You will write this function

keyFilename = input('Enter the filename for your key image (or hit enter to use key.png):','s');

% Use the default name if one wasn't entered
if (length(keyFilename) == 0)
    keyFilename = 'key.png'; % no name entered, so default to 'key.png'
end

% Save our key to a png image
imwrite(keyImage,keyFilename);

% Next embed the key image within another image to hide it.
colourImageFilename = input('Enter the filename of a colour image to embed the key in:','s');
colourImage = imread(colourImageFilename);
hiddenImage = EmbedImage(keyImage,colourImage);

hiddenFilename = input('Enter the filename for your hidden key image (or hit enter to use hiddenKey.png):','s');

% Use the default name if one wasn't entered
if (length(hiddenFilename) == 0)
    hiddenFilename = 'hiddenKey.png'; % no name entered, so default to 'hiddenKey.png'
end

imwrite(hiddenImage,hiddenFilename);

% Display the generated key
figure(1)
imshow(keyImage)
title('Key image');

function outimage = ImageComplement(outimage)
outimage=uint8(outimage);

for i = 1: size(outimage,1)
    for j = 1:size(outimage,2)
        outimage(i,j)= 255-outimage(i,j);
    end
end
end
function output= AlterByOne(input)
if input ==255
    output=input-1;
else
    output=input+1;
end
end
function image= PatternsToImage(key) % converts cell array to normal array

image=cell2mat(key);
end
function key= GenerateKey(r,p) % generates a cell array r of values from p
for i = 1:size(r,1)
    for j = 1:size(r,2)
        key{i,j}=p{r(i,j)};
    end
end
end
function pattern=CreatePatterns() % creates 2*2 patten of 2 black and 2 white pixels
pattern{1}=uint8([255,255;0,0]);
pattern{2}=uint8([0,0 ; 255,255]);
pattern{3}=uint8([0,255 ; 0, 255]);
pattern{4}=uint8([255,0;255,0]);
pattern{5}=uint8([0,255;255,0]);
pattern{6}=uint8([255,0;0,255]); %didn't bother using the ImageComplement thing just felt this would be quicker

end


function cipherArray= EncryptImage(PlainImage,KeyArray)
cipherArray=cell(size(PlainImage,1),size(PlainImage,2)); %setting size to make it faster
for i = 1:size(PlainImage,1)
    for j= 1:size(PlainImage,2)%running through every pixel
        if PlainImage(i,j)<128 %dark pixel
            cipherArray{i,j}=ImageComplement(KeyArray{i,j}); %complement of the relevant key cell
        else %light pixel
            cipherArray{i,j}=KeyArray{i,j};
        end
    end
end
end


% Copy and Paste your submission below.
function imageOutput = ExtractImage(colimage)
colimage = double(colimage);
for i = 1:size(colimage,1)
    for j = 1:size(colimage,2)
        oddtoddandevensteven = colimage(i,j,1) + colimage(i,j,2) + colimage(i,j,3);
        if ((mod(oddtoddandevensteven,2)) == 1)
            imageOutput(i,j) = 255;
        elseif ((mod(oddtoddandevensteven,2)) == 0)
            imageOutput(i,j) = 0;

        end
    end
end
imageOutput=uint8(imageOutput);
end

function EmbeddedImage= EmbedImage(bin,rgb) % takes in input binary image and rgb image changes red subpixel so that every white pixel leads to odd sm of all rgb sub pixels and black leads to even sum of rgb subpixels
EmbeddedImage=rgb;
rgb=double(rgb); % conerting it to double so that the sum can go over 255

for i = 1:size(bin,1)
    for j = 1:size(bin,2)
        if mod(rgb(i,j,1)+rgb(i,j,2)+rgb(i,j,3),2)==1 && bin(i,j)==0 % black pixel and odd sum
            EmbeddedImage(i,j,1)=AlterByOne(rgb(i,j,1));
        elseif  mod(rgb(i,j,1)+rgb(i,j,2)+rgb(i,j,3),2)==0 && bin(i,j)==255 % white pixel and even sum
            EmbeddedImage(i,j,1)=AlterByOne(rgb(i,j,1));
        end


    end
end
EmbeddedImage=uint8(EmbeddedImage); %just in case
end
function image= DecryptImage(cipher,key)
cipher=uint8(cipher);
key=uint8(key);
image=bitcmp(bitxor(cipher,key),"uint8"); %allows for the 1,0,0,1 truth table we require for this function
end
