for aaa=0:3
    
    
   [elapsedTime reShapedData sensorTimeAverages] = ProcessNanoMuxFile;
   avgs(aaa + 1,:,:) = sensorTimeAverages;
    
end

xx=0:3;
for rr=1:32
    
    yy1 = avgs(:,rr,1);
    yy2 = avgs(:,rr,2);
    
    plot(xx,yy1,xx,yy2)
    
    tempString = sprintf('Current vs Source-Drain Voltage, Device Row #%i',rr);
    title(tempString);
    xlabel('Source-Drain Voltage (V)');
    ylabel('Current (\muA)');
    %ylim([0.000 5]);
    legend('Column1','Column2','FontSize',8);
    pause(1);
    
    tempString = sprintf('Current vs Source-Drain Voltage, Device Row #%i',rr);
    saveas(gcf,tempString,'jpg')
    
end