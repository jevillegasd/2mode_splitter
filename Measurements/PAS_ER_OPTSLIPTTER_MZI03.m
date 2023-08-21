% Calculate the ER beqteen the outputs of the optimized 2-mode splitter

%% Adiabatic TE0 to TE1 Coupler
die = "jvillegas02";
circuits = ["topo_MZI_03","topo_MZI_03"];
%outputs_ref = ["Output_1_topo_MZI_02","Output_1_topo_MZI_02"];
outputs_ref = ["",""];
outputs = ["Output_2","Output_1"];

gauss_size = 30; %in 10s of pm
plot_step = 10;

figure(1), clf, hold on;
ER_wav = [] ; ER = [];
P = []; P_s = [];
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    wav= data{1}.wav;
    
    P_s(:,i) = smoothdata(data{1}.P,'gaussian',3);
    P(:,i) = smoothdata(data{1}.P,'gaussian',gauss_size);
    
    %Plot measured power
end
xlim([1520 1580])

subplot(2,1,1)  
plot(wav,P_s(:,1),'--'); hold on;
plot(wav,P_s(:,2), '--');  
plot(wav,P(:,1),'-','LineWidth',2);
plot(wav,P(:,2), '-','LineWidth',2); 
xlim([1520 1580])
%% Caluclate the ER between TE1 and TE0

    FSR = 3.3; %in nm, theminimum expected FSR to distinguis MZI peaks
    dx = wav(2)-wav(1);

    %To calculate imbalance we find max and min peaks:
    peakp = 8; 
    peakwmin = ceil(FSR/3/dx);
    peakwmax = ceil(FSR/dx);

    [te0_peak, idx1] = findresonances(P(:,1),'MinPeakProminence',peakp);
    [te1_peak, idx2] = findresonances(P(:,2),'MinPeakProminence',peakp);
    maxidx = min(length(idx1),length(idx2));

    %Then we calculate the local ER for each peak as
    
    ER_wav0 = wav(idx1(1:maxidx)); ER_wav1 = wav(idx2(1:maxidx));
    te1_peak = te1_peak(1:maxidx); te0_peak = te0_peak(1:maxidx);
    idx_erase = (abs(ER_wav1-ER_wav0)>FSR);
    % These peaks are spaced more than one FSR so may not be from an MZI resoannce
    ER_wav0(idx_erase) = []; te1_peak(idx_erase) = [];
    ER_wav1(idx_erase) = []; te0_peak(idx_erase) = [];

    ER_TE0 = te0_peak' - P(idx1,2);
    ER_TE1 = te1_peak' - P(idx2,1);

    % We take the wavelength at which the ER was measured as that exactly
    % between the two resonance peaks (shopuld be equivalent at zero crossing)

    subplot(2,1,2)
    
    scatter(ER_wav0,ER_TE0,'o','LineWidth',2); hold on;
    scatter(ER_wav1,ER_TE1,'x','LineWidth',2); 
%%

subplot(2,1,1)
legend({"","","TE0","TE1"})
format_plot(gca,'Wavelength (nm)','Transmittance (dB)',2,'double')
xlim([1530 1570])
subplot(2,1,2)
legend({"TE0","TE1"})
ER_lin = 10.^(ER_TE1./10);
format_plot(gca,'Wavelength (nm)','ER (dB)',2,'double')
xlim([1530 1570])

