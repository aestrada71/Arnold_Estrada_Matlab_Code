function [f_pd, f_p, varargout] = fit_phase(Iin, tin, f)

dt=tin(2)-tin(1);
Nsamp_per=round((1/f)/dt)*2;
t=tin(1:Nsamp_per);


I_pd=mean(reshape(Iin(:,2),[Nsamp_per size(Iin,1)/Nsamp_per]),2);
I_p=mean(reshape(Iin(:,1),[Nsamp_per size(Iin,1)/Nsamp_per]),2);


f_pd = fit(t,I_pd, 'a+b*sin(2*pi*800*x-phi)');
f_p = fit(t,I_p, 'a+b*sin(2*pi*800*x-phi)');

if(nargout>2)
    varargout(1)={f_pd.m(1)+f_pd.m(2)*sin(2*pi*f*t-f_pd.m(3))};
    varargout(2)={f_p.m(1)+f_p.m(2)*sin(2*pi*f*t-f_p.m(3))};
end



