% to view result files

clear all

pause (0.1);
[fname,pname] = uigetfile('*.*', 'TIF data file');
Openfile = [pname, fname];
showlines = imread(Openfile,1);
[numlines, nx] = size(showlines);

figure

subplot(1,2,1)

imagesc(showlines); %f_niceplot;
title({[fname]});
axis image;
colormap gray;
set(gca, 'XTickLabel', [])
ylabel('line number')


pause(0.1);
[fname,pname] = uigetfile('*.mat', 'processed data file');
Openfile = [pname, fname];
load(Openfile);


subplot(2,2,2);
plot(Result(:, 1), Result(:,5)*180/pi)
ylabel('angle')
xlabel('line number')

subplot(2,2,4);
plot(Result(:, 2), Result(:,3), '.')
xlabel('time (ms)')
ylabel('velocity (mm/s)')