% Data stored in a table name data_TE0
% 
clear all;
load('data_losses.mat')
gauss_size = 5e2; %in 10s of pm
wav = data_TE1.wav;
P = zeros(3, length(wav)); ref = P; P_s = P;

P_s(1,:) = smoothdata(data_TE1.n10,'gaussian',3);
P_s(2,:) = smoothdata(data_TE1.n20,'gaussian',3);
P_s(3,:) = smoothdata(data_TE1.n30,'gaussian',3);


P(1,:) = smoothdata(data_TE1.n10,'gaussian',gauss_size);
P(2,:) = smoothdata(data_TE1.n20,'gaussian',gauss_size);
P(3,:) = smoothdata(data_TE1.n30,'gaussian',gauss_size);

ref(1,:) = smoothdata(data_TE1.ref10,'gaussian',gauss_size);
ref(2,:) = smoothdata(data_TE1.ref20,'gaussian',gauss_size);
ref(3,:) = smoothdata(data_TE1.ref30,'gaussian',gauss_size);

P_norm = P-ref;

figure(1), clf
colors = linspecer(3); %help hsv
colors = colors(1:3,:);

%scatter(wav,P_s-ref,'x','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',.1, 'HandleVisibility','off'), hold on;
plot(wav,P_s-ref,'--','HandleVisibility','off'), hold on;
set(gca,'linestyleorder',{'-',':','-.','--'},...
    'colororder',colors,...
    'nextplot','add')
plot(wav,P_norm,'-','LineWidth',2),

xt = [];
for i = 1:length(P_norm)
    xt(i) = mean(P_norm(:,i));
end
plot(wav,xt,'--','color','black','LineWidth',2), hold off

legend({"N=10","N=20","N=30"})
format_plot(gca,'Wavelength (nm)','Transmitance (dB)', 3,'flatter')

