% Plot data from 
% coupler_IMB_TE0_0: Input TE0 to multiplexer
% coupler_IMB_TE0_1: Input TE0 to multiplexer
% coupler_IMB_TE1_0: Input TE1 to multiplexer
% coupler_IMB_TE1_1: Input TE1 to multiplexer

%% Adiabatic TE0 to TE1 Coupler
die = "jvillegas02";
circuits = ["coupler_IMB_TE0_0","coupler_IMB_TE1_0","coupler_IMB_TE0_1", "coupler_IMB_TE1_1"];
outputs_ref = ["Output_1_coupler_IMB_TE0_0","Output_1_coupler_IMB_TE1_0","Output_1_coupler_IMB_TE0_1","Output_1_coupler_IMB_TE1_1"];
outputs = ["Output_2","Output_2","Output_2","Output_2"];
colors = ['r','r','b','b'];
gauss_size = 100; %in 10s of pm
plot_step = 10;

figure(1), clf, 
ER_wav_TE0 = [] ; ER_TE0 = [];
ER_wav_TE1 = [] ; ER_TE1 = [];
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    wav= data{1}.wav;
    
    P = smoothdata(data{1}.P,'gaussian',gauss_size);
    
    %Plot measured power
    subplot(1,2,1)
    plot(wav, P, '-'); 
    hold on; grid on;
    FSR = 3.3; %in nm, theminimum expected FSR to distinguis MZI peaks
    dx = wav(2)-wav(1);
    %To calculate imbalance we find max and in peaks:
    peakp = 0.5; 
    peakwmin = ceil(FSR/3/dx);
    peakwmax = ceil(FSR/dx);
    [tp, idx1] = findpeaks(P,'MinPeakProminence',peakp, 'MinPeakWidth',peakwmin, 'MaxPeakWidth',peakwmax);
    [mp, idx2] = findpeaks(-P,'MinPeakProminence',peakp);
    maxidx = min(length(idx1),length(idx2));

    %Then we calculate the local ER for each peak as
    
    ER_wav0 = wav(idx1(1:maxidx)); ER_wav1 = wav(idx2(1:maxidx));
    mp = mp(1:maxidx); tp = tp(1:maxidx);
    idx_erase = (abs(ER_wav1-ER_wav0)>FSR);
    % These peaks are spaced more than one FSR so may not be from an MZI resoannce
    ER_wav0(idx_erase) = []; mp(idx_erase) = [];
    ER_wav1(idx_erase) = []; tp(idx_erase) = [];

    % We take the wavelength at which the ER was measured as that exactly
    % between the two resonance peaks (shopuld be equivalent at zero crossing)

    subplot(1,2,2)

    if (colors(i) == 'r')
        ER_wav_TE0 = [ER_wav_TE0; (ER_wav0+ER_wav1)/2]; 
        ER_TE0 = [ER_TE0; (-mp(:)-tp(:))];
        scatter(ER_wav_TE0,ER_TE0,colors(i)); hold on;
    else
        ER_wav_TE1 = [ER_wav_TE1; (ER_wav0+ER_wav1)/2]; 
        ER_TE1 = [ER_TE1; (-mp(:)-tp(:))];
        scatter(ER_wav_TE1,ER_TE1,colors(i)); hold on;
    end
end
%%

subplot(1,2,1)
legend({"TE0","TE1",""})
format_plot(gca,'Wavelength (nm)','Transmittance( dB)',2,'double')

subplot(1,2,2)

ER_lin = 10.^(ER_TE1./10);
A = (1-ER_lin)./(1+ER_lin);

c_coeff = A./(1+A); %Coupling coefficeint assuming no losses

newx = (wav-1550);
ERx = (ER_wav_TE1-1550);
[P,R] = polyfit(ERx,c_coeff,3);
[fity,DELTA] = polyval(P,newx,R);

yyaxis right
plot(wav,fity,'LineWidth',2);
plot(wav,fity+DELTA,'LineStyle','--','color','#FFAAAA','LineWidth',1);
plot(wav,fity-DELTA,'LineStyle','--','color','#FFAAAA','LineWidth',1);  hold on
ylabel('Cross Coupling')
ylim([0 0.5])
grid on; hold off;
format_plot(gca,'Wavelength (nm)','Cross Coupling (dB)',2,'double')


