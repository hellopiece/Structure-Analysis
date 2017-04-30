clear
clc
% 获得数据
getdata

%------------------column_x,column_y 表示柱子尺寸
%------------------floor_x,floor_y 表示建筑尺寸
%------------------density_con 混凝土密度
%------------------E 弹性模量

% 计算柱和板的惯性矩
I = 1.0/6*column_x*power(column_y, 3);
A = column_x * column_y;
m = floor_x*floor_y*density_con*0.5;

kk1 = [E*A/height  	0                       0                      -E*A/height   0                       0;
	   0 			12*E*I/power(height,3)  6*E*I/power(height,2)  0             -12*E*I/power(height,3) 6*E*I/power(height,2);
	   0            6*E*I/power(height,2)   4*E*I/height           0             -6*E*I/power(height,2)  2*E*I/height;
	   -E*A/height  0                       0                      E*A/height           0                0;
       0            -12*E*I/power(height,3) -6*E*I/power(height,2) 0             12*E*I/power(height,3)  -6*E*I/power(height,2);
       0            6*E*I/power(height,2)   2*E*I/height           0             -6*E*I/power(height,2)  4*E*I/height];

T = [0 -1 0 0 0 0; 1 0 0 0 0 0; 0 0 1 0 0 0; 0 0 0 0 -1 0; 0 0 0 1 0 0; 0 0 0 0 0 1];
num_gan = floors * 2;

% 获得单元矩阵
k_gan = T' * kk1 * T;

% 获得定位矩阵
dingwei{1} = [1 0 0 0 0 0]';
dingwei{2} = [1 0 0 0 0 0]';
n = 2;
for nums=3:2:num_gan-1
	dingwei{nums} = [n 0 0 n-1 0 0]';
	dingwei{nums+1} = dingwei{nums};
	n = n + 1;
end

% 获得整体矩阵
K = zeros(floors);
for nums = 1: num_gan
	for dw_x=1:4
		for dw_y=1:4
			if(dingwei{nums}(dw_x) ~= 0 && dingwei{nums}(dw_y) ~= 0)
				K(dingwei{nums}(dw_x), dingwei{nums}(dw_y)) = k_gan(dw_x, dw_y) + K(dingwei{nums}(dw_x), dingwei{nums}(dw_y));
			end
		end
	end
end

% 检验K是否对称
for x = 2:floors
	for y = 1:x-1
		if(K(x, y) == K(y, x))
			K_is_sem = 1;
		else
			K_is_sem = 0;
			break;
		end
	end
end

% 获得M阵
M = eye(floors)*m;

% 风荷载
for nums=1:floors
	z = nums*3;
	if(z<10)
		w = 1.4*1.3*power(1, 0.3)*0.45;
	else
		w = 1.4*1.3*power(z*1.0/10, 0.3)*0.45;			
    end
	
	if(nums == floors)
		% 顶层取一半面积
		p(nums) = w*0.5*floor_x*height*0.5;
	else
		p(nums) = w*0.5*floor_x*height;
    end
end
p = p';

% 计算位移
delta = K\p
	
% 是否符合限值
cenggaobi = delta(floors)/z;
if(cenggaobi < 1.0/550)
	disp('符合限值');
else
	disp('不符合限值');
end

% 计算结构的频率
syms u;
ww = eye(floors)*u;
kk = K - ww * M;
u = double(solve(det(kk)));
w = sqrt(u);

% 振型
[v, d] = eig(K);
for nums=1:floors
	Y{nums} = v(:,1);
	
	% 归一化
	Y{nums} = Y{nums}/Y{nums}(1);
end

% 排序
for x=1:floors-1
	for y=1:floors-1
		if(w(y)>w(y+1))
			temp = w(y);
			temp_y = Y{y};
			w(y) = w(y+1);
			Y{y} = Y{y+1};
			w(y+1) = temp;
			Y{y+1} = temp_y;
		end
	end
end

disp('自振频率')
w

disp('振型')
for nums=1:floors
    disp(Y{nums})
end

