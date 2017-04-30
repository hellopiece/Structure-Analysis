clc
clear	% ��ʼ������
[filename, pathname] = uigetfile({'*.txt', 'All txt Files'; '*.*', 'All Files'}, '��ѡ���ļ�', 'MultiSelect', 'on');
myfilename = strcat(pathname, filename);
[fidin, message] = fopen(myfilename, 'r');		% �������ļ�

if fidin == -1
	disp(message);

else
   [floors, height, floor_x, floor_y, height_ban, num_column, column_x, column_y, density_con, E] ...
       = textread(myfilename, 'floors%d height%d floor_x%f floor_y%f height_ban%f columns%d column_x%f column_y%f density%f E=%f ', 1);
   fclose(fidin);
   density_con = density_con * 1000;
   E = E*10^7;
end

