% Plot data reference data for normalization TE

%% Adiabatic TE0 to TE1 Coupler
die = "jvillegas";
circuits = ["test_TE"];
outputs_ref = [""];
outputs = ["Output_1"];
colors = ['b'];
gauss_size = 300; %in 10s of pm
plot_step = 10;

figure(1), clf, 
ER_wav_TE0 = [] ; ER_TE0 = [];
ER_wav_TE1 = [] ; ER_TE1 = [];
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    wav= data{1}.wav;
    
    P_s = smoothdata(data{1}.P,'gaussian',3);
    P = smoothdata(data{1}.P,'gaussian',gauss_size);
    %Plot measured power
    plot(wav,P_s,'--'); hold on;
    plot(wav, P, 'r','LineWidth',2); 
end

%%
refP = P;
set(gca,'FontSize',12,'FontName','Arial')
grid on; hold off;
xlim([1520 1580])
format_plot(gca,'Wavelength (nm)','Transmittance (dB)', 1,'flatter')

