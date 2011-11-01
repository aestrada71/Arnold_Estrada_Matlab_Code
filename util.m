dt=time(2)-time(1);
Nsamp_per=round((1/f)/dt)*2;
t=time(1:Nsamp_per);


I_pd=mean(reshape(Iin(:,2),[Nsamp_per size(Iin,1)/Nsamp_per]),2);
I_p=mean(reshape(Iin(:,1),[Nsamp_per size(Iin,1)/Nsamp_per]),2);

[P_est,P_mod]=lifetimefit(f,t,I_p);
[Pd_est,Pd_mod]=lifetimefit(f,t,I_pd);


% P_fit=P_est(1)+P_est(2)*sin(2*pi*f*t-P_est(3));
% Pd_fit=Pd_est(1)+Pd_est(2)*sin(2*pi*f*t-Pd_est(3));
[sse, P_fit]=P_mod(P_est);
[sse, Pd_fit]=Pd_mod(Pd_est);



hold off
plot(t, I_pd./(2*mean(I_pd)));
hold on
plot(t, I_p./(2*mean(I_p)), '*');
plot(t, P_fit/(2*mean(P_fit)));

ascData(:,1)=t;
ascData(:,2)=I_p/(2*mean(I_p));
ascData(:,3)=I_pd/(2*mean(I_pd));
ascData(:,4)=P_fit/(2*mean(P_fit));

dlmwrite('2cyclePhaseData_500.txt',ascData);