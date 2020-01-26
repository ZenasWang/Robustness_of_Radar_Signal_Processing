

[myscenario, egoVehicle] = scenario();

bepPlot = birdsEyePlot('XLim',[-10 50],'YLim',[-40 40]);
outlineplotter = outlinePlotter(bepPlot);
laneplotter = laneBoundaryPlotter(bepPlot);
legend('off')

detPlotter = detectionPlotter(bepPlot,'DisplayName','Radar detections', ...
    'MarkerFaceColor','b');

rb = roadBoundaries(egoVehicle);
[position,yaw,length,width,originOffset,color] = targetOutlines(egoVehicle);    
plotLaneBoundary(laneplotter,rb)
plotOutline(outlineplotter,position,yaw,length,width, ...
            'OriginOffset',originOffset,'Color',color)
        
        
positions = [30 5; 30 -10; 30 15];
velocities = [-10 0; -10 3; -10 -4];
labels = {'D1','D2','D3'};
plotDetection(detPlotter,[positions; position]);