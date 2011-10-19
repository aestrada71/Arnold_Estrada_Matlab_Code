function z=meanfilt(x,N)
% produces an N-point mean filter of data in vector x
%   z=meanfilt(x,N)

b=ones(1,N)/N;
ind=find((isnan(x)==1) | isinf(x)==1);
if(isempty(ind))
    z=filtfilt(b,1,x);
else
    disp('Warning: setting all NaN values to zero.');
    x(ind)=0;
    z=filtfilt(b,1,x);
    z(ind)=NaN;
end

