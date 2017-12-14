% clear;clc;

%% Read files
c = [3,6];
td = [10,20,30];
num = 0:1;
% N = [120,60,40;240,120,80];
 M=[2000,2000,2000;2000,2000,2000];
N = [60,60,60;120,120,120];
%M=[1000,1000,1000;1000,1000,1000];
AssignObj = zeros(length(num),length(td),length(c),2);
AssignTime= zeros(length(num),length(td),length(c),2);
AssignStatus= zeros(length(num),length(td),length(c),2);
Assign = cell(length(td),length(c),2);
PriceObj = cell(length(td),length(c),2);
Price = cell(length(td),length(c),2);
PriceTime = cell(length(td),length(c),2);
PriceStatus= cell(length(td),length(c),2);
PriceCorr = cell(length(td),length(c),2);
Utility = cell(length(td),length(c),2);
Value = cell(length(td),length(c),2);
for j = 1:length(td)
    for i = 1:length(c)        
        n = N(i,j);
        PriceObj{j,i,1} =[];
        Price{j,i,1}=[];
        PriceTime{j,i,1}=[];
        PriceStatus{j,i,1}=[];
        Assign{j,i,1} =[];
        Utility{j,i,1} = []; 
        Value{j,i,1} = []; 
        PriceObj{j,i,2} =[];
        Price{j,i,2}=[];
        PriceTime{j,i,2}=[];
        PriceStatus{j,i,2}=[];
        Assign{j,i,2} =[];
        Utility{j,i,2} = []; 
        Value{j,i,2} = []; 
        for k = 1:length(num)
            path_peak = sprintf('results/c=%d/td=%d/result_fast%d_%d_peak.txt',c(i),td(j),num(k)+M(i,j),n);
             value_peak = sprintf('dat/c=%d/td=%d/value%d_peak.dat',c(i),td(j),num(k)+M(i,j));
            path_uniform = sprintf('results/c=%d/td=%d/result_fast%d_%d_uniform.txt',c(i),td(j),num(k)+M(i,j),n);
            value_uniform = sprintf('dat/c=%d/td=%d//value%d_uniform.dat',c(i),td(j),num(k)+M(i,j));
            pathtext = fileread(path_peak);
            eval(pathtext);
            AssignObj(k,j,i,2) = assignObj;
            AssignTime(k,j,i,2) = assigntime;
            AssignStatus(k,j,i,2) = assignStatus;
            Assign{j,i,2}=[Assign{j,i,2},assign(:,2)];
            PriceObj{j,i,2}=[PriceObj{j,i,2};priceObj];
            Price{j,i,2} = [Price{j,i,2};price];
            PriceTime{j,i,2}=[PriceTime{j,i,2};time];
            PriceStatus{j,i,2} = [PriceStatus{j,i,2};status];
            
            pathtext = fileread(value_peak);
            eval(pathtext);
            value = reshape(value,720,n);
            utility = zeros(1,n);
            v = zeros(1,n);
            for m = 1:n
                utility(m) = value(assign(assign(:,1)==m,2)+1,m)-price(m);
                v(m) = value(assign(assign(:,1)==m,2)+1,m);
            end
            Value{j,i,2} =  [Value{j,i,2};v];
            Utility{j,i,2} =  [Utility{j,i,2};utility];
            clear  assignObj assigntime assignStatus price priceObj time status utility
            pathtext = fileread(path_uniform);
            eval(pathtext);
            AssignObj(k,j,i,1) = assignObj;
            AssignTime(k,j,i,1) = assigntime;
            AssignStatus(k,j,i,1) = assignStatus;
            Assign{j,i,1}=[Assign{j,i,1},assign(:,2)];
            PriceObj{j,i,1}=[PriceObj{j,i,1};priceObj];
            Price{j,i,1} = [Price{j,i,1};price];
            PriceTime{j,i,1}=[PriceTime{j,i,1};time];
            PriceStatus{j,i,1} = [PriceStatus{j,i,1};status];
            pathtext = fileread(value_uniform);
            eval(pathtext);
            value = reshape(value,720,n);
            utility = zeros(1,n);
            v = zeros(1,n);
            for m = 1:n
                utility(m) = value(assign(assign(:,1)==m,2)+1,m)-price(m);
                v(m) = value(assign(assign(:,1)==m,2)+1,m);
            end
            Value{j,i,1} =  [Value{j,i,1};v];
            Utility{j,i,1} =  [Utility{j,i,1};utility];
        end
    end
end



%% Plot figures: 1. Price

figure(1);clf;hold on;

line= {'-','--'};
linewidth={1.6,0.4};
color={'r','b','k'};
marker = {'.','+'};
titles = {'1)','2)','3)'};
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        
        x = 0:0.01:10;
        pd = fitdist(reshape(Price{j,i,1},size(Price{j,i,1},1)*size(Price{j,i,1},2),1),'Kernel','BandWidth',0.5);
        y1 = pdf(pd,x);
        plot(x,y1,[color{1},line{i}],'linewidth',linewidth{1})
        Legend = [Legend,sprintf('c=%d,uniform',c(i))];
%         
        x = 0:0.1:10;
        pd = fitdist(reshape(Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1),'Kernel','BandWidth',0.5);
        y2 = pdf(pd,x);
        plot(x,y2,[color{2},line{i}],'linewidth',linewidth{2})
        Legend = [Legend,sprintf('c=%d,peak',c(i))];
%         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
    legend(Legend,'Location','ne')
    legend('boxoff')
    set(gcf,'color',[1,1,1])
    axis([0,10,0,.8]);
    ylabel('Probability density function');
    xlabel(sprintf('Price\n %s s=%dmin',titles{j},td(j)));
        set(gca,'xTick',0:2:10)

    set(gca,'fontname','times new roman', 'fontsize',10)
end
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
saveas(gcf,'price.pdf');
%% Plot figures: 2. Utility
figure(2);clf;hold on;
linewidth={1.6,0.4};
line= {'-','--'};
color={'r','b','k'};
marker = {'+','o'};
titles = {'1)','2)','3)'};
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        
        x = 0:0.1:10;
        pd = fitdist(reshape(Utility{j,i,1},size(Utility{j,i,1},1)*size(Utility{j,i,1},2),1),'Kernel','BandWidth',0.5);
        y1 = pdf(pd,x);
        plot(x,y1,[color{1},line{i}],'linewidth',linewidth{1})
        Legend = [Legend,sprintf('c=%d,uniform',c(i))];
%         
        x = 0:0.1:10;
        pd = fitdist(reshape(Utility{j,i,2},size(Utility{j,i,2},1)*size(Utility{j,i,2},2),1),'Kernel','BandWidth',0.5);
        y2 = pdf(pd,x);
        plot(x,y2,[color{2},line{i}],'linewidth',linewidth{2})
        Legend = [Legend,sprintf('c=%d,peak',c(i))];
%         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
    legend(Legend,'Location','ne')
    legend('boxoff')
    set(gcf,'color',[1,1,1])
    axis([0,10,0,.8]);
    ylabel('Probability density function');
%     xlabel(sprintf('Utility\n\n%s  td=%dmin',titles{j},td(j)));
    xlabel(sprintf('Utility\n %s s=%dmin',titles{j},td(j)));
        set(gca,'xTick',0:2:10)

    set(gca,'fontname','times new roman', 'fontsize',10)
end
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4)-0.01;
ax.Position = [left bottom ax_width ax_height];
saveas(gcf,'utility.pdf');
%% Plot figures: 3. Value

figure(3);clf;hold on;
linewidth={1.6,0.4};
line= {'-','--'};
color={'r','b','k'};
marker = {'+','o'};
titles = {'1)','2)','3)'};
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        
        x = 0:0.1:10;
        pd = fitdist(reshape(Value{j,i,1},size(Value{j,i,1},1)*size(Value{j,i,1},2),1),'Kernel','BandWidth',0.5);
        y1 = pdf(pd,x);
        plot(x,y1,[color{1},line{i}],'linewidth',linewidth{1})
        Legend = [Legend,sprintf('c=%d,uniform',c(i))];
%         
        x = 0:0.1:10;
        pd = fitdist(reshape(Value{j,i,2},size(Value{j,i,2},1)*size(Value{j,i,2},2),1),'Kernel','BandWidth',0.5);
        y2 = pdf(pd,x);
        plot(x,y2,[color{2},line{i}],'linewidth',linewidth{2})
        Legend = [Legend,sprintf('c=%d,peak',c(i))];
%         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
    legend(Legend,'Location','ne')
    legend('boxoff')
    set(gcf,'color',[1,1,1])
    axis([0,10,0,.8]);
    ylabel('Probability density function');
%     xlabel(sprintf('value\n\n%s  td=%dmin',titles{j},td(j)));
    xlabel(sprintf('Value\n %s s=%dmin',titles{j},td(j)));
    set(gca,'xTick',0:2:10)
    set(gca,'fontname','times new roman', 'fontsize',10)
    
end
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4)-0.01;
ax.Position = [left bottom ax_width ax_height];
saveas(gcf,'value.pdf');

%% individual plot

c1 = 3;
c2 = 3;
td1 = 20;
td2 = 20;
id1 = 1;
id2 = 2;
f1 = 4;
f2 = 5;
f3 = 6;
f4 = 7;
figure(f1);clf;hold on;
individual(Assign{2,1,1}(:,id1),td1*ones(length(Assign{2,1,1}),1),Value{2,1,1}(id1,:),Price{2,1,1}(id1,:),2,c1,30,f1);
hc = colorbar(gca,'NorthOutside');
hc.Ticks = 0:0.2:1;
hc.TickLabels = {'0','4','8','12','16','20'};
saveas(gcf,sprintf('individual%d_3_20_uniform.pdf',id1+999))
figure(f2);clf;hold on;
individual(Assign{2,1,1}(:,id2),td1*ones(length(Assign{2,1,1}),1),Value{2,1,1}(id2,:),Price{2,1,1}(id2,:),2,c1,30,f2);
saveas(gcf,sprintf('individual%d_3_20_uniform.pdf',id2+999))
figure(f3);clf;hold on;
individual(Assign{2,1,2}(:,id1),td1*ones(length(Assign{2,1,2}),1),Value{2,1,2}(id1,:),Price{2,1,2}(id1,:),2,c1,30,f3);
saveas(gcf,sprintf('individual%d_3_20_peak.pdf',id1+999))
figure(f4);clf;hold on;
individual(Assign{2,1,2}(:,id2),td1*ones(length(Assign{2,1,1}),1),Value{2,1,2}(id2,:),Price{2,1,2}(id2,:),2,c1,30,f4);
saveas(gcf,sprintf('individual%d_3_20_peak.pdf',id2+999))

%% individual prob

c1 = 3;
c2 = 3;
td1 = 20;
td2 = 20;
figure(8);clf;hold on;
subplot(1,2,1);hold on;
for id = 1:100
    [y,x] = ecdf(Price{1,1,1}(id,:));
    plot(x,y,'r')
    [y,x] = ecdf(Price{1,1,2}(id,:));
    plot(x,y,'b')
    legend('uniform','peak','Location','ne');
    legend('boxoff')
    xlabel('Price')
    ylabel('Cumulative distribution function')
    set(gca,'FontName','Times new roman','FontSize',10)
end

axis([0,10,0,1])
set(gcf,'color',[1,1,1])
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

subplot(1,2,2);hold on;
for id = 1:100
    [y,x] = ecdf(Value{1,1,1}(id,:));
    plot(x,y,'r')
    [y,x] = ecdf(Value{1,1,2}(id,:));
    plot(x,y,'b')
    legend('uniform','peak','Location','ne');
    legend('boxoff')
    xlabel('Value')
    ylabel('Cumulative distribution function')
    set(gca,'FontName','Times new roman','FontSize',10)
end
axis([0,10,0,1])
set(gcf,'color',[1,1,1])
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
saveas(gcf,'cdf10_3.pdf')

%% Plot figures: 1. Price

figure(11);clf;hold on;

line= {'-','--'};
color={'r','b','k'};
marker = {'+','o'};
titles = {'','',''};
avP = zeros(3,2,2);
avV = zeros(3,2,2);
avU = zeros(3,2,2);
stdP = zeros(3,2,2);
stdV = zeros(3,2,2);
stdU = zeros(3,2,2);
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        avP(j,i,1) = mean(reshape(Price{j,i,1},size(Price{j,i,1},1)*size(Price{j,i,1},2),1));
        avP(j,i,2) = mean(reshape(Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1));
        avV(j,i,1) = mean(reshape(Value{j,i,1},size(Value{j,i,1},1)*size(Value{j,i,1},2),1));
        avV(j,i,2) = mean(reshape(Value{j,i,2},size(Value{j,i,2},1)*size(Value{j,i,2},2),1));
        avU(j,i,1) = mean(reshape(Value{j,i,1}-Price{j,i,1},size(Price{j,i,1},1)*size(Price{j,i,1},2),1));
        avU(j,i,2) = mean(reshape(Value{j,i,2}-Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1));
        stdP(j,i,1) = std(reshape(Price{j,i,1},size(Price{j,i,1},1)*size(Price{j,i,1},2),1));
        stdP(j,i,2) = std(reshape(Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1));
        stdV(j,i,1) = std(reshape(Value{j,i,1},size(Value{j,i,1},1)*size(Value{j,i,1},2),1));
        stdV(j,i,2) = std(reshape(Value{j,i,2},size(Value{j,i,2},1)*size(Value{j,i,2},2),1));
        stdU(j,i,1) = std(reshape(Value{j,i,1}-Price{j,i,1},size(Price{j,i,1},1)*size(Price{j,i,1},2),1));
        stdU(j,i,2) = std(reshape(Value{j,i,2}-Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1));

%         TT1 = zeros(720,1);
%         for t = 1:720
%             idx = find(AA1==t);
%             if ~isempty(idx)
%                 TT1(t) = mean(PP1(idx));
%             end
%         end
%         II1 = find(TT1>1e-3);
%         plot(II1*2,TT1(II1),'k.')    
%         axis([420,900,0,10])
%         x = 0:0.01:10;
%         pd = fitdist(,'Kernel','BandWidth',0.5);
%         y1 = pdf(pd,x);
%         plot(x,y1,[color{1},line{i}])
%         Legend = [Legend,sprintf('c=%d,td=%dmin,uniform',c(i),td(j))];
% %         
%         x = 0:0.1:10;
%         pd = fitdist(reshape(Price{j,i,2},size(Price{j,i,2},1)*size(Price{j,i,2},2),1),'Kernel','BandWidth',0.5);
%         y2 = pdf(pd,x);
%         plot(x,y2,[color{2},line{i}])
%         Legend = [Legend,sprintf('c=%d,td=%dmin,peak',c(i),td(j))];
% %         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
%     legend(Legend,'Location','ne')
%     legend('boxoff')
%     set(gcf,'color',[1,1,1])
%     axis([0,10,0,.8]);
%     ylabel('Probability density');
%     xlabel('Price');
%         set(gca,'xTick',0:2:10)
% 
%     set(gca,'fontname','times new roman', 'fontsize',14)
end
% set(gcf,'Units','Inches');
% pos = get(gcf,'Position');
% set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% saveas(gcf,'price.pdf');
%% Plot figures: 2. Utility
figure(12);clf;hold on;

line= {'-','--'};
color={'r','b','k'};
marker = {'+','o'};
titles = {'','',''};
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        
        x = 0:0.1:10;
        pd = fitdist(reshape(Utility{j,i,1},size(Utility{j,i,1},1)*size(Utility{j,i,1},2),1),'Kernel','BandWidth',0.5);
        y1 = pdf(pd,x);
        plot(x,y1,[color{1},line{i}])
        Legend = [Legend,sprintf('c=%d,td=%dmin,uniform',c(i),td(j))];
%         
        x = 0:0.1:10;
        pd = fitdist(reshape(Utility{j,i,2},size(Utility{j,i,2},1)*size(Utility{j,i,2},2),1),'Kernel','BandWidth',0.5);
        y2 = pdf(pd,x);
        plot(x,y2,[color{2},line{i}])
        Legend = [Legend,sprintf('c=%d,td=%dmin,peak',c(i),td(j))];
%         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
    legend(Legend,'Location','ne')
    legend('boxoff')
    set(gcf,'color',[1,1,1])
    axis([0,10,0,.8]);
    ylabel('Probability density');
%     xlabel(sprintf('Utility\n\n%s  td=%dmin',titles{j},td(j)));
    xlabel('Utility')
        set(gca,'xTick',0:2:10)

    set(gca,'fontname','times new roman', 'fontsize',14)
end
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
saveas(gcf,'utility.pdf');
%% Plot figures: 3. Value

figure(13);clf;hold on;

line= {'-','--'};
color={'r','b','k'};
marker = {'+','o'};
titles = {'','',''};
for j = 1:length(td)
    subplot(1,3,j);hold on;
    Legend={};

    for i = 1:length(c)
%         [f,x] = ecdf(reshape(Price{j,i,1},1,size(Price{j,i,1},1)*size(Price{j,i,1},2)));
%         plot(x,f,[color{i},line{1}])
%         [f,x] = ecdf(reshape(Price{j,i,2},1,size(Price{j,i,2},1)*size(Price{j,i,2},2)));
%         plot(x,f,[color{i},line{2}])
        
        x = 0:0.1:10;
        pd = fitdist(reshape(Value{j,i,1},size(Value{j,i,1},1)*size(Value{j,i,1},2),1),'Kernel','BandWidth',0.5);
        y1 = pdf(pd,x);
        plot(x,y1,[color{1},line{i}])
        Legend = [Legend,sprintf('c=%d,td=%dmin,uniform',c(i),td(j))];
%         
        x = 0:0.1:10;
        pd = fitdist(reshape(Value{j,i,2},size(Value{j,i,2},1)*size(Value{j,i,2},2),1),'Kernel','BandWidth',0.5);
        y2 = pdf(pd,x);
        plot(x,y2,[color{2},line{i}])
        Legend = [Legend,sprintf('c=%d,td=%dmin,peak',c(i),td(j))];
%         PriceCorr{j,i} = corrcoef(Price{j,i}');
    end
    legend(Legend,'Location','ne')
    legend('boxoff')
    set(gcf,'color',[1,1,1])
    axis([0,10,0,.8]);
    ylabel('probability density');
%     xlabel(sprintf('value\n\n%s  td=%dmin',titles{j},td(j)));
    xlabel('Value')
    set(gca,'xTick',0:2:10)
    set(gca,'fontname','times new roman', 'fontsize',14)
    
end
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
saveas(gcf,'value.pdf');