function drawTree(s,varargin)
% Draws a cluster diagram in the format of "Cluster analysis and display of 
% genome-wide expression patterns," Eisen et al. using a cluster
% Inputs
%   s           The root sensorPair which contains all information in the
%               sensor tree (cluster), as output by computeSensorCluster.m
%   varargin    Optional argument which sets the figure number to draw the
%               diagram on

% If the figure number is given, record this
setFig = size(varargin,2) > 0;

% Get the position of this sensorPair
pos = get(s,'Pos');

% If the sensorPair is a single node (i.e. contains no sub-sensorPairs),
% draw a label at the node's position to indicate what channel it is, then
% stop.
if ~isa(get(s,'Sensor1'),'sensorPair')
    hold on;
    if setFig
        figure(varargin{1});
    end
    chLabel = ['Ch. ' num2str(get(s,'Index'))];
    
    text(pos(1),pos(2),chLabel,'HorizontalAlignment','Center','VerticalAlignment','Top');
    return;
end

% Get the positions of the two sub-sensorPairs
s1 = get(s,'Sensor1');
s2 = get(s,'Sensor2');
s1Pos = get(s1,'Pos');
s2Pos = get(s2,'Pos');

% Set the positions of the lines to be drawn (from each of the
% sub-sensorPairs up, then in toward the containing sensorPair)
x = zeros(1,4);
y = zeros(1,4);
x(1) = s1Pos(1);
y(1) = s1Pos(2);
x(4) = s2Pos(1);
y(4) = s2Pos(2);
x(2) = x(1);
y(2) = pos(2);
x(3) = x(4);
y(3) = pos(2);

% Plot the lines connecting this sensorPair to its sub-sensorPairs
hold on;
if setFig
    figure(varargin{1});
end
axis([0 1 0 1]);
axis off;
plot(x,y);

% Recursively continue, using each of the two sub-sensorPairs as a new root
% node
if setFig
    drawTree(s1,varargin{1});
    drawTree(s2,varargin{1});
else 
    drawTree(s1);
    drawTree(s2);
end


end