%Written by Alex Greis
%9/17/07
%Last Updated: 10/17/2007
    %Given 2d double array, variable width, variable height
    %This function plots these points on a 2d plane, with coordinates int,int;
    %then connects them with a line sequentially
%Update: 10/16/2007
    %Allows for argument dots. If argument is present a dot plot is drawn
    %instead of a line plot
    %fixed an indexing error
%Update: 10/17/2007
    %fixed a bug that caused the function to terminate before plotting
function plot2d(A,dots,output)
%process input arguments-------------------------
if (nargin ~= 3)
    error('Plot2d:Num_Args','Incorrect number of Arguments passed in');
end
%------------------------------------------------
%init
newplot;
hold on;    %allows more than one plot without clearing
start=1;
temp=0;
start_n=1;
num_coords=0;
term=0;
%temporary vectors 
X=[];
Y=[];
V=[];
R=[];
S=[];

while(term==0)
    count=start;
    start_n=start;
    num_coords=0;
    
    %determine how many coordinates in current vector (end indicated by -1
    %in x coordinate
    while(count <= (size(A,1)))
        start_n=start_n+1;
        if(A(count,1)==-1)
            %count=count+1;
            break;
        end
        num_coords=num_coords+1;
        count=count+1;
    end
    
    %if end of A is reached, set term =1;
    if(count>size(A,1))
        term=1;
    end
    %fill temporary vectors with values
    count = start;
    temp = 1;
    while(count <= (start+num_coords-1))
        X(temp)= A(count,1);
        Y(temp)= A(count,2); %axis is inverted
        V(temp)= vpa(A(count,6),3); %These values PO2 readings, must be entered with overlay_PO2 or function will break
        R(temp)= vpa(A(count,7),2);
        S(temp)= vpa(A(count,8),2);
        count=count+1;
        temp=temp+1;
    end
    count=temp-1;
    temp=start+num_coords-1;
    if(count==0)
        term=1;
    end
    
    %plot temp vectors - dots or line
    if (dots==0)
        plot(X,Y,'-ro','LineWidth',2,'MarkerSize',6, 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    else
        plot(X,Y,'ro','LineWidth',2,'MarkerSize',6, 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    end
    %axis([0 256 0 256]);
    colormap bone;
    %add readings to graph
    count =1;
    size(X,2)
    while(count<=size(X,2))
    %Build String to be output determined by 'output' argument
    outStr = num2str(V(count));
    if (output==0) %po2
        outStr = num2str(V(count));
    end
    if (output==1) %po2 + r
        outStr = strcat(outStr,' (',num2str(R(count)),')');
    end
    if (output==2) %po2 + magnitude
        outStr = strcat(outStr,' (',num2str(S(count)),')');
    end
    if (output==3) %po2 + r + magnitude
        outStr = strcat(outStr,' (',num2str(R(count)),' , ',num2str(S(count)),')');
    end
    text(X(count)+3,Y(count),outStr,'FontSize',13,'FontWeight','bold','Color','white');
    count=count+1;
    end
    
    %update starting value for next loop
    start=start_n;
    
end

