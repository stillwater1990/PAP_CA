%function individual_plot(ID,mod,type)
% ID: ID of the file
% type: fast - fast algorithm; 'standard' - standard algorithm
clear;clc;
ID = 209; % 224 
mod = 1;
a = []; % start time of the interval
b = []; % end time of the interval 
n = 0; % number of request
c = 0; % number of slots
td = []; % time duration of the requests

T = 1440;
type = 'fast';
if strcmp(type,'fast') 
    path='result';
else
    path='result_normal';
end
clear price assign time
datpath = strcat('a0stw',num2str(ID),'.dat');
dat = fileread(datpath);
eval(dat(170:end));    

figure(1);clf;hold on;
T = 1440;
H = 30;
for i = 0:c
    plot([0,T],[(i)*H,(i)*H],'k-');
end
axis([420,840,0,c*H]);
set(gca,'yTick',0:H:c*H);
set(gca,'xTick',0:60:1440);
set(gca,'yTickLabel',0:1:c);
set(gca,'xTickLabel',0:60:1440);

assign = [];
resultpath = strcat(path,num2str(ID),'_',num2str(mod),'.txt');
valuepath = strcat('value',num2str(ID),'_',num2str(mod),'.dat');
result = fileread(resultpath);
eval(result);
v = fileread(valuepath);
eval(v);
value = reshape(value,[T,n]);
occupy = zeros(c,1440);
slotassign = zeros(n,1);
[values, order] = sort(assign(:,2));
sortedassign = assign(order,:);
for j = 1:n
   color(sortedassign(j,1),:) = [max(rand(),0.2),max(rand(),0.2),max(rand(),0.2)];
    for i = 1:c
        if sum(occupy(i,sortedassign(j,2):sortedassign(j,2)+td(sortedassign(j,1))-1))==0            
            rectangle('Position',[sortedassign(j,2),(i-1)*H,td(sortedassign(j,1)),H],'FaceColor',color(sortedassign(j,1),:),'EdgeColor',color(sortedassign(j,1),:))       
            occupy(i,sortedassign(j,2):sortedassign(j,2)+td(sortedassign(j,1))-1) = 1;
            slotassign(sortedassign(j,1)) = i;
            
            break;
        end        
    end
end

for i = 1:c
    slotnum(i) = sum(slotassign==i);
end

aa = [a;1:n];
[values, order] = sort(aa(1,sortedassign(:,1)) );
aorder = aa(2,order);

slotcount = zeros(3,1);
for jj = 1:n
    j = aorder(jj);
    h2 = 0.8/slotnum(slotassign(sortedassign(j,1)));
    h1 = slotcount(slotassign(sortedassign(j,1)))*h2+0.1;
    slotcount(slotassign(sortedassign(j,1))) = slotcount(slotassign(sortedassign(j,1))) + 1;
    %if sortedassign(j,2)>=a(sortedassign(j,1))-1e-3 && sortedassign(j,2)<=b(sortedassign(j,1))+1e-3
    %    continue;
    %else
        rectangle('Position',[a(sortedassign(j,1)),(slotassign(sortedassign(j,1))-1)*H+h1*H,b(sortedassign(j,1))-a(sortedassign(j,1)),h2*H],'FaceColor',color(sortedassign(j,1),:),'EdgeColor','k')
        text(a(sortedassign(j,1))/2+b(sortedassign(j,1))/2-2,(slotassign(sortedassign(j,1))-1)*H+h1*H+0.5,num2str(sortedassign(j,1)))
    %end
end

for j = 1:n
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-2,(slotassign(sortedassign(j,1))-1)*H+1,num2str(sortedassign(j,1)))
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-2,(slotassign(sortedassign(j,1))-1)*H+H-1,num2str(price(sortedassign(j,1)),'%1.1f'))
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-2,(slotassign(sortedassign(j,1))-1)*H+H-2.5,num2str(value(sortedassign(j,2),sortedassign(j,1))-price(sortedassign(j,1)),'%1.1f'))

end

% Price1{i,j} = price;
% assign1 = assign;
% Time1(i,j) = assigntime+sum(time);    
% num(i) = max(num(i),length(price));
% result2 = fileread(resultpath2);
% eval(result2);        
% Price2{i,j} = price;
% assign2 = assign;
% Time2(i,j) = assigntime+sum(time);
% num(i) = max(num(i),length(price));
