clear;clc;
figure(1);clf;hold on;
set(gcf,'color',[1,1,1])
x = 400:1:450;
y = min(min(x-400,452-x),20*ones(1,length(x)));
y(x<410)=0;
y(x>442)=0;
plot(x,y,'ko', 'markersize', 5)
axis([400,450,0,30]);
x2 = 400:10:450;
y2 = y(ismember(x,x2));
plot(x2,y2,'k.', 'markersize', 10)
legend('time discretization of 1min','time discretization of 10min')
legend('boxoff')
xlabel('Time','FontName','Times new roman','FontSize',14);
ylabel('Valuation','FontName','Times new roman','FontSize',14)

set(gca,'FontName','Times new roman','FontSize',14)
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4)-0.01;
ax.Position = [left bottom ax_width ax_height];
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
saveas(gcf,'time_discretization.pdf');