function [ X,Y ] = fct_make_galv_sigs( Nlines, lineRate ,sampleRate)
%This function creates the x and y signals for the galvos.
%  The return signals will range from -0.5 to 0.5.


% N = Nlines*Npts_in_a_line;
Npts_in_a_line = floor(sampleRate / lineRate);
N = Npts_in_a_line * Nlines;
    
    
    
    
Y = linspace(0,5,N);

for ii = 1:(Npts_in_a_line):(N-Npts_in_a_line+1);
    Y(ii:ii+(Npts_in_a_line-1)) = ii/((N-Npts_in_a_line+1));%scale from 0 to 1
end

Y = Y-0.5 ;                      %shift to -0.5 to +0.5 

t = linspace(0,2*pi*Nlines,N);
X = 0.5*(sawtooth(t,0.8));        %shift to -0.5 to +0.5 


% add a delay
N_Tail = 10 * Npts_in_a_line ;        %Add tail to slowly bring y mirror back to min.

yTail = linspace(0.5, -0.5, N_Tail);
xTail = zeros(1,N_Tail)-0.5;

X = [X xTail];
Y = [Y yTail];

X=transpose(X);
Y=transpose(Y);
% figure(1);
% subplot(2,1,1)
% plot(Y(N+N_Tail-N_Tail:N+N_Tail));
% subplot(2,1,2)
% plot(X(N+N_Tail-N_Tail:N+N_Tail));