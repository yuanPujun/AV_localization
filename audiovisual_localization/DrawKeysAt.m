function [a,b,c]=DrawKeysAt(window,x,y,size)
% TrueLocation Color: blue [0,0,255]
% KeysColor: white [255,255,255]
% TextBound: [1383,735,1394,750]; 11,15

positions = zeros(2, 5);  % postion matrix
positions(1, :) = x;  % x-coordinates
positions(2, :) = y;  % y-coordinates

Screen('DrawDots', window, positions, size, [0,0,255], [], 1);

for i=1:5

    [a,b,c]=DrawFormattedText(window, num2str(i), x(i)-6, y+30, 255);

end

end