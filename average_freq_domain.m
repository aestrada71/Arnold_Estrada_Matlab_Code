f=10000;

[I,t]=daqread(sprintf('Rhodamine_%ihz.daq',f));

Ipd_sq = zeros(size(I(:,2)));
Ipd_sq(find(I(:,2)>0.7))=1;
Ipmt= I(:,1);
Ipd=I(:,2);

ind=find(diff(Ipd_sq) > 0.5);
t_pulse = t(ind);

dt=t(2)-t(1);
T=1/f;
N=2*round(T/dt);
Ipd2=zeros(N+1,length(t_pulse)-1);
Ipmt2=zeros(N+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    Ipd2(:,ipulse)=Ipd(ind(ipulse):ind(ipulse)+N);    
    Ipmt2(:,ipulse)=Ipmt(ind(ipulse):ind(ipulse)+N);   
end
tnew=(0:size(Ipd2,1)-1)*dt;

Ipmtm=mean(Ipmt2,2);
Ipdm=mean(Ipd2,2);





