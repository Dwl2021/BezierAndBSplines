close all;clear;clc;

Degree = 5;  % b样条次数
N = 10;  % 定义控制点的个数

if N <= Degree
    assert(false,'Control Points must be more than Degree!');
end

Xi = linspace(0,N-Degree+2,N-Degree+3);
Xi = [Xi(1),repmat(Xi(2), 1, Degree), Xi(3:end-2), repmat(Xi(end-1), 1, Degree),Xi(end)]; % 在两端重复首尾值Degree次

figure;
axis([0 10 0 10]);
hold on; 

CtrlPoints = zeros(N, 2);
for i = 1:N
    [x, y] = ginput(1);
    CtrlPoints(i,:) = [x, y];
    plot(x, y, 'Color', [0, 0.4470, 0.7410],'MarkerSize',40,'Marker','.');
end

[CurvePoints, Basis] = CalculateBSplineCurve(Degree, Xi, CtrlPoints);
plot(CurvePoints(:,1), CurvePoints(:,2), '-', 'Color', [0.6350, 0.0780, 0.1840], 'LineWidth', 2);
hold on;
plot(CtrlPoints(:,1), CtrlPoints(:,2), 'o--', 'Color', [0, 0.4470, 0.7410], ...
    'MarkerFaceColor', [0, 0.4470, 0.7410], 'MarkerSize', 40,'Marker','.');
hold off;

legend('B-Spline Curve', 'Control Points');
xlabel('X');
ylabel('Y');
title(sprintf('B-Spline Curve of Degree %d', Degree),'FontSize',24);


function [CurvePoints, Basis] = CalculateBSplineCurve(Degree, Xi, CtrlPoints)
    [Evals, Basis] = CoxdeBoor(Degree, Xi, Degree+1, length(Xi)-Degree);
    CurvePoints = zeros(length(Evals), size(CtrlPoints, 2));
    for i = 1:size(CtrlPoints, 1)
        for j = 1:size(CtrlPoints, 2)
            CurvePoints(:, j) = CurvePoints(:, j) + Basis(i, :).' .* CtrlPoints(i, j);
        end
    end
end



function [Evals, Basis] = CoxdeBoor(Degree,Xi,From,To)


Knots = unique(Xi(From:To));
Sub = 30;

% One overlap (Sub-1) and use the knot-spans
Evals = zeros((Sub-1)*(length(Knots)-1)+1,1);
for j = 1:length(Knots)-1
  if j == 1
    Evals(1:Sub) = linspace(Knots(j),Knots(j+1),Sub);
  else
    Evals((Sub-1)*(j-1)+1:(Sub-1)*j+1) = linspace(Knots(j),Knots(j+1),Sub);
  end  
end


% B-splines are defined on half-open knot intervals, so the last knot is not included.
Evals(end) = Evals(end) - 1e-4;

NumberBasis = length(Xi) - Degree - 1;
k = NumberBasis + Degree;
m = length(Evals);
TempBasis = zeros(k,m);

for B = 1:k
  % All values in Evals
  for n = 1:m
    t = Evals(n);
    if Xi(B) <= t && t < Xi(B+1)
      TempBasis(B,n) = 1;
    end
  end
end

Basis = Recurse(Degree,Xi,Evals,1,TempBasis);

% -----------------------------------------------------------------------
end

function CurrentTempBasis = Recurse(Degree,Xi,Evals,Current,PrevTempBasis)
k = size(PrevTempBasis,1)-1;
m = size(PrevTempBasis,2);
CurrentTempBasis = zeros(k,m);

for B = 1:k
  for n = 1:m
    t = Evals(n);
    
    if Xi(B+Current) - Xi(B) ~= 0
      CurrentTempBasis(B,n) = ((t-Xi(B))/(Xi(B+Current)-Xi(B))) * PrevTempBasis(B,n);
    end
    
    if Xi(B+Current+1) - Xi(B+1) ~= 0
      CurrentTempBasis(B,n) = CurrentTempBasis(B,n) + ((Xi(B+Current+1)-t)/(Xi(B+Current+1)-Xi(B+1))) * PrevTempBasis(B+1,n);
    end
  end
end

if Current ~= Degree
  CurrentTempBasis = Recurse(Degree,Xi,Evals,Current+1,CurrentTempBasis);
end
end

% -----------------------------------------------------------------------
