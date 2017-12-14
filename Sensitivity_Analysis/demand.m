clear;clc;
type = {'_uniform','_peak'};
for i = 1000:1000
     figure(1);clf;hold on;
    for j = 1:2
        path = strcat('demand',num2str(i),type{j},'.txt');
        dat = fileread(path);
        eval(dat);        
        plot(demand);
        saveas(gcf,strcat('demand',num2str(i),'.png'));
    end
    set(gcf,'color',[1,1,1])
    set(gcf,'LineWidth',1)
    legend('uniform','peak')
    legend('boxoff')
    
%     figure(2);clf;hold on;
%     for j = 1:2
%         path = strcat('prob',num2str(i),'_60.txt');
%         dat = fileread(path);
%         eval(dat);        
%         plot(p);
%         saveas(gcf,strcat('prob_60.png'));
%     end
%     set(gcf,'color',[1,1,1])
%     legend('uniform','peak')
%     legend('boxoff')
end