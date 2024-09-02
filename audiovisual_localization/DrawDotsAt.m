function dispersion=DrawDotsAt(window,x,y,stdx,stdy,size)
% Color: white [255,255,255]
% Num_Dots: 20

positions = zeros(2, 20);          % postion matrix
positions(1, :) = x + stdx * randn(1, 20);  % x-coordinates
positions(2, :) = y + stdy * randn(1, 20);  % y-coordinates
dispersion = std(positions(1, :));           % trial-by-trial std

Screen('DrawDots', window, positions, size, 255, [], 1);

end