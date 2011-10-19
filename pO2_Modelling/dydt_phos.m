function dy = dydt(t,y,K_phos, xsection, fr, C)


h = 6.626e-34;          %Plancks constant (J.s).

dy2 = -K_phos*y(2) + 0.5 * xsection * fr* (C - y(2));