close all;clear;clc;

gif_save = 'Bezier2.gif'; % GIF文件的名称

% 定义三个控制点
P0 = [0, 0];
P1 = [1, 2];
P2 = [3, 1];

% 定义t的范围和步长
t = 0:0.01:1;

% 初始化贝塞尔曲线的坐标数组
Bx = zeros(size(t));
By = zeros(size(t));

figure;
% 计算并绘制贝塞尔曲线
for i = 1:length(t)
    % 计算贝塞尔曲线上的点
    Bx(i) = (1-t(i))^2*P0(1) + 2*(1-t(i))*t(i)*P1(1) + t(i)^2*P2(1);
    By(i) = (1-t(i))^2*P0(2) + 2*(1-t(i))*t(i)*P1(2) + t(i)^2*P2(2);

    % 清除当前图形窗口
    clf;
    
    % 绘制控制点和控制多边形
    plot([P0(1), P1(1), P2(1)], [P0(2), P1(2), P2(2)], 'ko-', 'MarkerFaceColor', 'black', 'MarkerSize', 8, 'LineWidth', 1.5);
    hold on;
    
    % 绘制贝塞尔曲线
    linewidth = 3;
    plot(Bx(1:i), By(1:i), 'LineWidth', linewidth, 'Color', [0.85, 0.33, 0.1]); % 深橙色线条
    
    % 动态绘制插值点和连接线
    P01 = (1-t(i))*P0 + t(i)*P1;
    P11 = (1-t(i))*P1 + t(i)*P2;
    P02 = (1-t(i))*P01 + t(i)*P11;
    
    % 绘制控制点到插值点的连线
    plot([P01(1),P11(1)],[P01(2),P11(2)],'Color', [0, 0.45, 0.74], 'LineStyle', '--', 'LineWidth',linewidth); % 蓝色
    
    % 绘制插值点
    marksize = 10;
    plot(P01(1), P01(2), 'o', 'MarkerFaceColor', [0, 0.45, 0.74], 'MarkerEdgeColor', 'k', 'MarkerSize', marksize); % 蓝色
    plot(P11(1), P11(2), 'o', 'MarkerFaceColor', [0, 0.45, 0.74], 'MarkerEdgeColor', 'k', 'MarkerSize', marksize); % 蓝色
    plot(P02(1), P02(2), 'o', 'MarkerFaceColor', [0.47, 0.67, 0.19], 'MarkerEdgeColor', 'k', 'MarkerSize', marksize); % 绿色
    
    % 设置图形属性
    axis equal;
    xlim([min([P0(1),P1(1),P2(1)])-1, max([P0(1),P1(1),P2(1)])+1]);
    ylim([min([P0(2),P1(2),P2(2)])-1, max([P0(2),P1(2),P2(2)])+1]);
    title(sprintf('t = %.2f', t(i)),'FontSize',24);
    
    % 捕获当前图形窗口的帧
    drawnow;
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    
    % 将帧写入GIF文件
    if i == 1
        imwrite(imind,cm,gif_save,'gif', 'Loopcount',inf, 'DelayTime', 0.01);
    else
        imwrite(imind,cm,gif_save,'gif','WriteMode','append', 'DelayTime', 0.01);
    end
   
    % 暂停以便观察动画效果
    pause(0.01);
    
    hold off;
end

close all;
