function [pks,locs] = findresonances(data,varargin)
    if iscolumn(data) == 1
        data = data';
    end
    [pks,locs]  = findpeaks(data,varargin{:}); 
    
    % Each peak gets fit to a Lorentizan and the resoannce center taken from the fit

    data_r = data-min(data);
    dl = round((locs(2)-locs(1))/2);
    for idx = 1:length(locs)
        x0 = max(1,locs(idx)-dl);
        x1 = min(length(data),locs(idx)+dl);

        y = data_r(x0:x1);
        x = linspace(x0,x1,length(y));
        
        p3 = ((max(x(:))-min(x(:)))./10).^2;
        p2 = (max(x(:))+min(x(:)))./2;
        p1 = max(y(:)).*p3; 
        c = min(y(:));
        p0 = [p1 p2 p3 c];
       
        opts = optimset('Display','off','TolFun',max(mean(y(:))*1e-8,1e-15),'TolX',max(mean(x(:))*1e-6,1e-15));
        [params,~,~,~,~,~,~] = lsqcurvefit(@lorentzian,p0,x,y,[],[],opts);
        locs(idx) = round(params(2));
        pks(idx) = data(locs(idx));
    end
end

function F = lorentzian(p,x)
    F = p(1)./((x-p(2)).^2+p(3)) + p(4);
end

function F = sinusoidal(p,x)
    F = p(1).*(exp(1i*(x-p(2))/p(3))+exp(-1i*(x-p(2))/p(3)))/2 + p(4);
end