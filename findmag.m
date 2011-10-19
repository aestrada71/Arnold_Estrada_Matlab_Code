function mag = findmag
NORMALIZE = 1;
% clear all;
[data,h] = avg_2p();

figure(1);
imagesc(data);
colormap('gray');

%data=log(data);

%Low pass filter the raw data to get rid of noise
data_f = fftshift(fft2(data));
[m n]=size(data);
mask = zeros([m n]);
filtSize = fix(m/2 * 0.12);
ind_m = (floor(m/2)-filtSize) : (ceil(m/2)+filtSize);
ind_n = (floor(n/2)-filtSize) : (ceil(n/2)+filtSize);
mask(ind_m, ind_n) = 1;
data_f = data_f .* mask;
data2 = abs(ifft2(data_f));

figure(2);
imagesc(data2);
colormap 'gray'

%Extract an arbitrary row or col
mid = data2(:,fix(m * 0.25)); 

%Normalize and Find the range of vals
if (NORMALIZE)
    Min = min(mid);
    mid = mid - Min;
    Max = max(mid);
    mid = mid * 1/Max;
end
%rectify signal to better define edges.Max = max(mid);          
Max = max(mid);
Min = min(mid);
delta = Max-Min;

%Get location of pxls with vals in bottom 80%
indices = find(mid < Min + (0.2.*delta)); 
midRect = zeros(numel(mid),1);
midRect(indices)=1;
xx=1:numel(midRect);
figure(3)
plot(xx,mid,xx,midRect);

%Take derivative of indices vector to find big jumps.
indicesDiff= diff(indices);         
%look for big jumps
 bigDiffInd = find(indicesDiff > (0.5*max(indicesDiff)));
 lineIndices = indices(bigDiffInd);

 spacing = mean(diff(lineIndices));
 %Average spacing between lines of protein
 spacing = round(spacing)
 
 %microns per pixel is
 micronsPerPxl = 20/spacing
 
 %find microns per mV (full swing) at galvo controller
 FOV = (micronsPerPxl * h.validX)
 micronsPerMVolt =  FOV/ ((h.xMax - h.xMin)*1000)
 