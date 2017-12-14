function individual(aa,td,value,price,TimeStep,c,H,ff)
figure(ff);clf;hold on;
n = length(aa);
T = 1440/TimeStep;
for i = 1:c
    rectangle('Position',[0,(i-1)*H,T*TimeStep,H],'FaceColor',[1,1,1]*1,'EdgeColor',[1,1,1]*0,'LineWidth',2)
end
axis([410,900,0,c*H]);
set(gca,'yTick',[]);
set(gca,'xTick',0:60:1440);
set(gca,'yTickLabel',[]);
set(gca,'xTickLabel',0:1:24);

assign = [(1:n)',aa*TimeStep];
[values, order] = sort(assign(:,2));
sortedassign = assign(order,:);
occupy = zeros(c,1440);
slotassign = zeros(n,1);

pmin = 0.3;
mp = colormap(gray(200));
for j = 1:n
   
    for i = 1:c
        if sum(occupy(i,sortedassign(j,2):sortedassign(j,2)+td(sortedassign(j,1))-1))==0    
            temp = abs(price(sortedassign(j,1)))^(1);
            color(sortedassign(j,1),:) = mp(ceil(temp*10^1)+1,:)*0.7+0.3;
            rectangle('Position',[sortedassign(j,2),(i-1)*H,td(sortedassign(j,1)),H],'FaceColor',color(sortedassign(j,1),:),'EdgeColor',[1,1,1]*0)       
            occupy(i,sortedassign(j,2):sortedassign(j,2)+td(sortedassign(j,1))-1) = 1;
            slotassign(sortedassign(j,1)) = i;
            
            break;
        end        
    end
end
for i = 1:c
 text(410,(i-1)*H+5,'Utility:','FontSize',11,'FontName','Times new roman');
  text(410,(i-1)*H+H/2,'Price:','FontSize',11,'FontName','Times new roman');
    text(410,(i-1)*H+H-5,'Value:','FontSize',11,'FontName','Times new roman');
end
for j = 1:n
%     text(sortedassign(j,2)+td(sortedassign(j,1))/2-2,(slotassign(sortedassign(j,1))-1)*H+1,num2str(sortedassign(j,1)))
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-4,(slotassign(sortedassign(j,1))-1)*H+5,num2str(ceil(value(sortedassign(j,1))*10)/10-ceil(price(sortedassign(j,1))*10)/10,'%1.1f'),'FontSize',12,'FontName','Times new roman')
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-4,(slotassign(sortedassign(j,1))-1)*H+H/2,num2str(ceil(abs(price(sortedassign(j,1)))*10)/10,'%1.1f'),'FontSize',12,'FontName','Times new roman')
    text(sortedassign(j,2)+td(sortedassign(j,1))/2-4,(slotassign(sortedassign(j,1))-1)*H+H-5,num2str(ceil(value(sortedassign(j,1))*10)/10,'%1.1f'),'FontSize',12,'FontName','Times new roman')
end

set(gca,'FontName','Times new roman','FontSize',14)
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
set(gcf,'color',[1,1,1]);
xlabel('Time (hr)')
ylabel('Slot')
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

for i = 0:c
    plot([0,T*TimeStep],[i*H,i*H],'k','LineWidth',2)
end

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4)-0.01;
ax.Position = [left bottom ax_width ax_height];
