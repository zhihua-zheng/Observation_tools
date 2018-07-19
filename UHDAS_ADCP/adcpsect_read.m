%--- adcpsect_read

%--- simple script to load the output from 'adcpsect' preprocessing, which
% gives 15min averaged data.

% The time variable is a zero-based decimal day: Noon on Jan 1 is 0.5 
% (not 1.5). All CODAS data follow this standard.

% zc is center of depth bins

%%

clear 
load contour_uv.mat
load contour_xy.mat

x=xyt(1,:)';
y=xyt(2,:)';
dday=xyt(3,:)';
u=uv(:,1:2:end);
v=uv(:,2:2:end);

badi=find(isnan(x));
x(badi)=[];
y(badi)=[];
dday(badi)=[];
u(:,badi)=[];
v(:,badi)=[];
