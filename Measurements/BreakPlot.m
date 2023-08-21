function h=BreakPlot(x,y,y_break_start,y_break_end,break_type)
% BreakPlot(x,y,y_break_start,y_break_end,break_type)
% Produces a plot who's y-axis skips to avoid unecessary blank space
% 
% INPUT
% x
% y
% y_break_start
% y_break_end
% break_type
%    if break_type='RPatch' the plot will look torn
%       in the broken space
%    if break_type='Patch' the plot will have a more
%       regular, zig-zag tear
%    if break_plot='Line' the plot will merely have
%       some hash marks on the y-axis to denote the
%       break
%
% USAGE:
% figure;
% BreakPlot(rand(1,21),[1:10,40:50],10,40,'Line');
% figure;
% BreakPlot(rand(1,21),[1:10,40:50],10,40,'Patch');
% figure;
% BreakPlot(rand(1,21),[1:10,40:50],10,40,'RPatch');
% figure;
% x=rand(1,21);y=[1:10,40:50];
% subplot(2,1,1);plot(x(y>=40),y(y>=40),'.');
% set(gca,'XTickLabel',[]);
% subplot(2,1,2);plot(x(y<=20),y(y<=20),'.');
%
% IT'S NOT FANCY, BUT IT WORKS.

% Michael Robbins
% robbins@bloomberg.net
% michael.robbins@bloomberg.net

% data
if nargin<5 break_type='RPatch'; end;
if nargin<4 y_break_end=40; end;
if nargin<3 y_break_start=10; end;
if nargin<2 y_=[1:10,40:50]; end;
if nargin<1 x_=rand(1,21); end;

if size(y,2) > size(y,1), y = y'; end

% Break going down
clf
h = axes;
hold on;
for j = 1:size(y,2)
    y_ = y(:,j);
    x_ = x
    if ~min(y_>y_break_start)
        
        y_break_mid=(y_break_end-y_break_start)./2+y_break_start;
        % erase useless data
        x_(y_>y_break_start & y_ <y_break_end)=[];
        y_(y_>y_break_start & y_ <y_break_end)=[];
        
       
        % leave room for the y_break_end
        
            [~,i]=max(y_<=y_break_end);
            if y_(i)>y_break_end
                x_=[x_(1:i-1) NaN x_(i:end)];
                y_=[y_(1:i-1) y_break_mid y_(i:end)];
            end
        
        % remap
        y2=y_; x2 = x_;
        x2(and(y2>=y_break_end,y2<y_break_start)) = [];
        y2(and(y2>=y_break_end,y2<y_break_start)) = [];

        y2(y2<=y_break_end) = y2(y2<=y_break_end)-y_break_end+y_break_start;
        
        % plot
        plot(h,x2,y2,'--','LineWidth',2);
    else
        plot(h,x_,y_,'-','LineWidth',2);
    end
end

    % make break
    xlim=get(gca,'xlim');
    ytick=get(gca,'YTick');
    [~,i]=min(ytick<=y_break_start);
    y_=(ytick(i)-ytick(i-1))./2+ytick(i-1);
    dy=(ytick(2)-ytick(1))./10;
    xtick=get(gca,'XTick');
    x_=xtick(1);
    dx=(xtick(2)-xtick(1))./2;
    y_ = y_break_start
    switch break_type
        case 'Patch',
            % this can be vectorized
            dx=(xlim(2)-xlim(1))./10;
            yy=repmat([y_-1.*dy y_+dy],1,6);
            xx=xlim(1)+dx.*[0:11];
            patch([xx(:);flipud(xx(:))], ...
                [yy(:);flipud(yy(:)-2.*dy)], ...
                [.8 .8 .8])
        case 'RPatch',
            % this can be vectorized
            dx=(xlim(2)-xlim(1))./100;
            yy=y_+rand(101,1).*2.*dy;
            xx=xlim(1)+dx.*(0:100);
            patch([xx(:);flipud(xx(:))], ...
                [yy(:);flipud(yy(:)-2.*dy)], ...
                [.8 .8 .8])
        case 'Line',
            line([x_-dx x_   ],[y_-2.*dy y_-dy   ],'k');
            line([x_    x_+dx],[y_+dy    y_+2.*dy],'k');
            line([x_-dx x_   ],[y_-3.*dy y_-2.*dy],'k');
            line([x_    x_+dx],[y_+2.*dy y_+3.*dy],'k');
    end
    set(h,'xlim',xlim);
    
    % map back
    ytick(ytick<y_break_start)=ytick(ytick<y_break_start)+y_break_end;
    for i=1:length(ytick)
       yticklabel{i}=sprintf('%d',ytick(i));
    end
    set(gca,'yticklabel',yticklabel);
    



