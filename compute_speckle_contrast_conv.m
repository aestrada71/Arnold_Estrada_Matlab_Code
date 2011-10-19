function z=compute_speckle_contrast_conv(Iraw,Navg)
%disp('hi')
SC=zeros(size(Iraw));

h=(ones(Navg,Navg)/(Navg*Navg));
Im=conv2(mean(Iraw,3),h,'same');

if(ndims(Iraw)>2)
    for i=1:size(Iraw,3)
        %Im=conv2(Iraw(:,:,i),h,'same');
        SC(:,:,i)=conv2(abs(Iraw(:,:,i)-Im),h,'same');                
    end
else
        %Im=conv2(Iraw,h,'same'); 
        SC=conv2(abs(Iraw-Im),h,'same');
end

SC=mean(SC,3)./Im;
z=SC;


















