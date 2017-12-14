clear;clc;
type = {'_uniform','_peak'};
td = 20;
c = 6;
marker = {'k-','k--'};
for i = 2000:2039
     figure(10);clf;hold on;
    for j = 1:2
        path = strcat('demand/c=',num2str(c),'/td=',num2str(td),'/demand',num2str(i),type{j},'.txt');
        dat = fileread(path);
        eval(dat);        
        plot(2:2:1440,demand/c,marker{j},'LineWidth',1);
       
        axis([0,1440,0,250])
    end
    set(gca,'xTick',0:240:1440)
    set(gca,'xTickLabel',(0:240:1440)/60)
    xlabel('Time (hr)');
    ylabel('Total value');
    set(gca,'FontName','Times new roman','FontSize',14)
     set(gcf,'color',[1,1,1])
    legend('uniform','peak')
    legend('boxoff')
    set(gcf,'Units','Inches');
    pos = get(gcf,'Position');
    set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
%     saveas(gcf,strcat('c=',num2str(c),'/td=',num2str(td),'/demand',num2str(i),'.png'));
    saveas(gcf, strcat('demand/c=',num2str(c),'/td=',num2str(td),'/demand',num2str(i),'.png'))
%     figure(2);clf;hold on;
%     for j = 1:2
%         path = strcat('prob',type{j},'_120.txt');
%         dat = fileread(path);
%         eval(dat);        
%         plot(p);
%         saveas(gcf,strcat('prob_60.png'));
%     end
%     set(gcf,'color',[1,1,1])
%     legend('uniform','peak')
%     legend('boxoff')
end