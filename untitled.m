clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
fontSize = 20;
% Create sample data.
% H = peaks(90);
H = Ambi/max(Ambi(:));

peaks=imregionalmax(H);
G=regionprops(peaks,'PixelIdxList');
% figure
% imagesc(peaks); % view max. peaks
r=struct2cell(G);
O=cell2mat(r);
Ambi_peak = H(O);
O = sort(Ambi_peak);
v=O(end-1)./O(end);
% 
% 
% % H = mat2gray(H);
% % Display it.
% subplot(2, 2, [1,2]);
% surf(H);
% xlabel('Azimuth [deg]', 'FontSize', fontSize);
% ylabel('Elevation [deg]', 'FontSize', fontSize);
% % Enlarge figure to full screen.
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]); % Maximize figure.
% set(gcf,'name','Demo by ImageAnalyst','numbertitle','off') 
% % Threshold the image
% binaryImage = H > 0.5;
% % Display it.
% subplot(2, 2, [3,4]);
% imshow(binaryImage);
% axis on;
% xlabel('Azimuth [deg]', 'FontSize', fontSize);
% ylabel('Elevation [deg]', 'FontSize', fontSize);
% measurements = regionprops(binaryImage, 'BoundingBox');
% bb = [measurements.BoundingBox]
% x1 = bb(1);
% x2 = x1 + bb(3);
% y1 = bb(2);
% y2 = y1 + bb(4);
% % Plot box over image.
% hold on;
% plot([x1 x2 x2 x1 x1], [y1 y1 y2 y2 y1], 'r-', 'LineWidth', 2);
% message = sprintf('The Azimuth Width at -3 dB = %.1f\nThe Elevation Width at -3 dB = %.1f', ...
%     bb(3), bb(4));
% msgbox(message);