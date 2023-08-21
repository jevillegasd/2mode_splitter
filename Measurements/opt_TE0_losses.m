% Data stored in a table name data_TE0
% 
clear all;
load('data_losses.mat')

gauss_size = 3e2; %in 10s of pm
wav = data_TE0.wav;
P = zeros(3, length(wav)); ref = P; P_s = P;

P_s(1,:) = smoothdata(data_TE0.n10,'gaussian',3);
P_s(2,:) = smoothdata(data_TE0.n20,'gaussian',3);
P_s(3,:) = smoothdata(data_TE0.n30,'gaussian',3);


P(1,:) = smoothdata(data_TE0.n10,'gaussian',gauss_size);
P(2,:) = smoothdata(data_TE0.n20,'gaussian',gauss_size);
P(3,:) = smoothdata(data_TE0.n30,'gaussian',gauss_size);

ref(1,:) = smoothdata(data_TE0.ref10,'gaussian',gauss_size);
ref(2,:) = smoothdata(data_TE0.ref20,'gaussian',gauss_size);
ref(3,:) = smoothdata(data_TE0.ref30,'gaussian',gauss_size);

P_norm = P-ref;
%%
figure(1), clf, subplot(2,1,1)
scatter(wav,P_s-ref,'x','MarkerFaceAlpha',0.1,'MarkerEdgeAlpha',.1,'color','black'), hold on;
plot(wav,P_norm,'-','LineWidth',2), hold off
ylabel(' Transmission (dB)'), xlabel('wavelength (nm)')
legend({"","","","N=10","N=20","N=30"})
format_plot(gca,'Wavelength (nm)','Insertion Loss (dB)', 3,'1c_double')

%% Calcuate losses
x = [10; 20; 30]*2;
X = [ones(length(x),1) x];

b = zeros(length(P_norm),2);
for i = 1: length(P_norm)
    b(i,:) = X\P_norm(:,i);
end
loss= b(:,2);

subplot(2,1,2), hold on
semilogy(wav,-loss,'LineWidth',2)
format_plot(gca,'Wavelength (nm)','Insertion Loss (dB)', 3,'1c_double')
