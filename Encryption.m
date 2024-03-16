% Step 2: Encryption
%
% This script encrypts a binary image (i.e. grayscale image containing
% contrasting black and white pixels), using a key that has been generated
% and then saved as an image.  The resulting cipher image is then embedded
% within a colour image to hide it.
% 
% For this script to work you will need to write the following functions:
% ImageToPatterns, EncryptImage, PatternsToImage, EmbedImage
%

plainImageFilename = input('Enter the filename of a binary image to encrypt:','s');

% Get image to encrypt
plainImage = imread(plainImageFilename); % will be a binary image (black/white)

keyImageFilename = input('Enter the filename for your key image (or hit enter to use key.png):','s');
% Use the default name if one wasn't entered
if (length(keyImageFilename) == 0)
    keyImageFilename = 'key.png'; % no name entered, so default to 'key.png'
end

% Get key to use
keyImage = imread(keyImageFilename);
% Convert key image to a cell array of patterns that we can work with
key = ImageToPatterns(keyImage); % You will write this function

% Encrypt the binary image using the key
cipher = EncryptImage(plainImage,key); % You will write this function
cipherImage = PatternsToImage(cipher); % You will write this function

% Write out the cipher image (not embbeded)
imwrite(cipherImage,'cipherImage.png');

% Next embed the cipher image within another image to hide it.
colourImageFilename = input('Enter the filename of a colour image to embed the cipher image in:','s');
colourImage = imread(colourImageFilename);
hiddenImage = EmbedImage(cipherImage,colourImage);

hiddenFilename = input('Enter the filename for your hidden cipher image (or hit enter to use hiddenCipher.png):','s');

% Use the default name if one wasn't entered
if (length(hiddenFilename) == 0)
    hiddenFilename = 'hiddenCipher.png'; % no name entered, so default to 'hiddenCipher.png'
end

imwrite(hiddenImage,hiddenFilename);

% Display the key and cipher images
figure(2)
subplot(1,2,1);
imshow(cipherImage)
title('Cipher image');
subplot(1,2,2);
imshow(keyImage);
title('Key image')



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
function patterns=ImageToPatterns(key)
x=2*ones(size(key,1)/2,1); % to allow the function to make a 2*2 out of any even sized vector
y=2*ones(size(key,2)/2,1);
patterns=mat2cell(key,x,y);
end