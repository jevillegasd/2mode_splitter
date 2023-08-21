%% Measure porportionality of TE0 and TE1 from resonance peaks
% Circuit topo_MZI_03 : MZI with input TE0 and output (1) TE0
%                                              output (2) TE1 [The output
% uses an adiabatic TE1 multiplexer in the output, with in->TE1 k = loss_modemuxTE1)

if (exist('loss_modemuxTE1')==0)
  load('muxref.mat'); % Run this script to get the losses of the TE1 coupling
end

load('data_losses.mat')
clear('P_ref')
gauss_size = 20; %in 10s of pm
wav = data_imbalance.wav;
P = zeros(2, length(wav)); P_ref = []; P_s = P;

P_s(1,:) = smoothdata(data_imbalance.TE0,'gaussian',3);
P_s(2,:) = smoothdata(data_imbalance.TE1,'gaussian',3);

P(1,:) = smoothdata(data_imbalance.TE0,'gaussian',gauss_size);
P(2,:) = smoothdata(data_imbalance.TE1,'gaussian',gauss_size);

P_ref = smoothdata(data_TE1.ref20,'gaussian',gauss_size);

P_ref = [P_ref P_ref-loss_modemuxTE1]';

P_norm = P-P_ref;

figure(1), clf
colors = linspecer(2); %help hsv
colors = colors(1:2,:);

%scatter(wav,P_s-ref,'x','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',.1, 'HandleVisibility','off'), hold on;
plot(wav,P_s-P_ref,'--','HandleVisibility','off'), hold on;
set(gca,'linestyleorder',{'-',':','-.','--'},...
    'colororder',colors,...
    'nextplot','add')
plot(wav,P_norm,'-','LineWidth',2), hold off
ylabel(' Transmission (dB)'), xlabel('wavelength (nm)')
legend({"TE0","TE1"});

%% Calcuate relationship between max power in TE0 and max power in TE1
figure(2)
[pks1,locs] = findresonances(P_norm(1,:),"MinPeakProminence",8); % Peaks TE0
[pks2,locs2] = findresonances(P_norm(2,:),"MinPeakProminence",8); % Peaks TE1

scatter(wav(locs),pks1); hold on
scatter(wav(locs2),pks2); 
l = min(length(pks1),length(pks2));
w2 = (wav(locs(1:l))+wav(locs2(1:l)))/2;
w2 = [wav(1); w2; wav(end)];

pks1 = [mean(pks1(1:ceil(l/8))) pks1(1:l) mean(pks1(l-ceil(l/8):end))];
pks2 = [mean(pks2(1:ceil(l/8))) pks2(1:l) mean(pks2(l-ceil(l/8):end))];

%%
w_ = w2-(min(w2)+max(w2))/2; f = max(pks1(1:l))-min(pks1(1:l));
y1 = pks1/f;
y2 = pks2/f;

fit = 2;
p1 = polyfit(w_,y1,fit);
p2 = polyfit(w_,y2,fit);

P_TE0= (polyval(p1,wav-(min(w2)+max(w2))/2))*f;
P_TE1= (polyval(p2,wav-(min(w2)+max(w2))/2))*f;

%P_TE0 = spline(w2,pks1,wav);
%P_TE1 = spline(w2,pks2,wav);


plot(wav,P_TE0,'--');
plot(wav,P_TE1,'--');
r = (P_TE1-P_TE0);

set(gca,'linestyleorder',{'-',':','-.','--'},...
    'colororder',colors,...
    'nextplot','add');
plot(wav,r,'b');
hold off;

%% Read trabsmission for TE0

gauss_size = 1e2; %in 10s of pm
wav = data_TE0.wav;
P = zeros(3, length(wav)); P_ref = P; P_s = P;

P_s(1,:) = smoothdata(data_TE0.n10,'gaussian',3);
P_s(2,:) = smoothdata(data_TE0.n20,'gaussian',3);
P_s(3,:) = smoothdata(data_TE0.n30,'gaussian',3);

P(1,:) = smoothdata(data_TE0.n10,'gaussian',gauss_size);
P(2,:) = smoothdata(data_TE0.n20,'gaussian',gauss_size);
P(3,:) = smoothdata(data_TE0.n30,'gaussian',gauss_size);

P_ref(1,:) = smoothdata(data_TE0.ref10,'gaussian',gauss_size);
P_ref(2,:) = smoothdata(data_TE0.ref20,'gaussian',gauss_size);
P_ref(3,:) = smoothdata(data_TE0.ref30,'gaussian',gauss_size);

P_norm = (P-P_ref)';

%% Calcuate losses for TE0
x = [10; 20; 30];
X = [ones(length(x),1) x];

b = zeros(length(P_norm),2);
for i = 1: length(P_norm)
    b(i,:) = X\P_norm(i,:)';
end
loss_TE0= b(:,2);

%% Project to TE1

loss_TE1 = loss_TE0+r;

figure(3), clf
plot(wav,loss_TE0,'-','LineWidth',2), hold on
plot(wav,loss_TE1,'-','LineWidth',2); hold off
legend({"TE0","TE1"});
set(gca,'linestyleorder',{'-',':','-.','--'},...
    'colororder',colors,...
    'nextplot','add')

xlim([1530 1570])
