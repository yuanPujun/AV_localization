function pixs=deg2pix(degree,inch,pwidth,vdist,ratio) 
% parameters: degree, inch (monitor size), pwidth (width in pixels), 
% vdist: viewsing distance
% ratio: ration = pheight/pwidth   
screenWidth = inch*2.54/sqrt(1+ratio^2);  % calculate screen width in cm 
pix=screenWidth/pwidth; %wRect(3); %calculates the size of a pixel in cm  
pixs = round(2*tan((degree/2)*pi/180) * vdist / pix); 