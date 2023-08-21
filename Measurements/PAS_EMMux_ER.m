% USing data from adiab_MZI_03 we measure the extinction ratio between the
% TE0,0 and TE0,1 outputs (TE0 and TE1 being the inputs)

load('adiabcouplerimbalance.mat')
data = adiabcouplerimbalance;
colors = linspecer(2); 

wav = data.wav; P=[];
P_s(:,1) = smoothdata(data.TE0,'gaussian',3);
P_s(:,2) = smoothdata(data.TE1,'gaussian',3);

gauss_size  = 100/10; %in 10s of pm
P(:,1) = smoothdata(data.TE0,'gaussian',gauss_size); % Data at TE0 port
P(:,2) = smoothdata(data.TE1,'gaussian',gauss_size); 

ref = smoothdata(data.ref,'gaussian',gauss_size); 
% if (isempty(loss_modemuxTE1))
%   multiplexer_TE1Coupling; % Run this script to get the losses of the TE1 coupling
% end
% ref = [ref ref-loss_modemuxTE1];

%ref = [refP refP]-3; % From the TE sraight waveguide measurement.
ref = [ref ref];

P_norm = P-ref;
figure(1), clf, subplot(2,1,1);
scatter(wav,P_s-ref,'x','MarkerEdgeAlpha',0.1); hold on;
plot(wav,P_norm,'-','LineWidth',2); hold off
legend({"","","TE_0_,_0","TE_0_,_1"})
set(gca, 'colororder',colors,...
    'nextplot','add')

%% Calculate ER for the Multiplexer
clear ('TE0_low','TE1_low','TE1_high','TE0_high')
[TE0_low,locs] = findresonances(-P_norm(:,1)',"MinPeakProminence",8); TE0_low = -TE0_low; % Peaks TE0
[TE1_low,locs2] = findresonances(-P_norm(:,2)',"MinPeakProminence",8); TE1_low = -TE1_low;% Peaks TE1

[TE0_high,locs_] = findresonances(P_norm(:,1)',"MinPeakProminence",8); % Peaks TE0
[TE1_high,locs2_] = findresonances(P_norm(:,2)',"MinPeakProminence",8); % Peaks TE1
idx_fsr = locs(2)-locs(1);

dl = length(locs) - length(locs2_);
if abs(dl) == 1
    len_a = min(length(locs) , length(locs2_));
    if abs(locs(1) - locs2_(1)) < idx_fsr/2 %REmove last peak in one of them
        locs = locs(1:len_a);  locs2_ = locs2_(1:len_a);
        TE0_low = TE0_low(1:len_a); TE1_high = TE1_high(1:len_a);
    else
        locs = locs(len(locs)-len_a+1:end);  locs2_ = locs2_(len(locs2_)-len_a+1:end);
        TE0_low = TE0_low(len(locs)-len_a+1:end); TE1_high = TE1_high(len(locs2_)-len_a+1:end);
    end
end

set(gca,"FontName",'Arial','FontSize',12)
format_plot(gca,'Wavelength (nm)','Transmittance (dB)',2,'double')
%%
%TE1_high = P_norm(locs,2)';
%TE0_high = P_norm(locs2,1)';

ER_01_mux = abs(TE0_high-TE1_low); % TE0/TE1 at TE0 port
ER_10_mux = abs(TE1_high-TE0_low); % TE1/TE0 at TE1 port

xlim([1530 1570])

subplot(2,1,2); cla;
plot(wav(locs2),ER_01_mux,'o','MarkerSize',8,'LineWidth',2); hold on 
plot(wav(locs),ER_10_mux,'s','MarkerSize',8,'LineWidth',2);
set(gca,"FontName",'Arial','FontSize',12)
legend({"ER_T_E_0", "ER_T_E_1"})
format_plot(gca,'Wavelength (nm)','ER (dB)',2,'double')
xlim([1530 1570])
