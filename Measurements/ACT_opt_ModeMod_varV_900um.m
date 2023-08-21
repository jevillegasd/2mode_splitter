%% Adiabatic TE0 to TE1 Coupler

% Description: Adiabatic coupler used as a mode modulator. Tested for
% volatges between -2.0 amnd 0 volts. USes a 400 um heater.
die = "jvillegas";
circuits = ["TE0_topo_DEV04"];
outputs_ref = ["Output_1_test_TE"]; % Output + circuit
outputs = ["Output_1"];
colors = ['r','b'];
gauss_size = 100/10; %in 10s of pm
plot_step = 10;

figure(2)
tcl = tiledlayout(2,1);

%% Plot TE0 Output
nexttile
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
   
    %Plot measured power
    leg_entries = {};
    for j = 1:length(data)
        P = smoothdata(data{j}.P,'gaussian',gauss_size);
        plot(data{j}.wav, P);
        v = str2double(data{j}.params.MeasuredVoltageCh2);
        i = str2double(data{j}.params.CurrentCh2)/4;
        leg_entries = [leg_entries, [num2str(v*i*1e3,'%.2f '), ' mW']];
        hold on; grid on;
    end
end
%title('Optimized TE1-TE0m Splitter - TE0 Output')
legend(leg_entries)
xlim([1520, 1580])
format_plot(gca,'Wavelength (nm)','Insertion Loss (dB)', 5,'1c_double',9)

%% Plot TE1 Output
outputs = ["Output_2"];
nexttile
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
   
    %Plot measured power
    leg_entries = {};
    for j = 1:length(data)
        P = smoothdata(data{j}.P,'gaussian',gauss_size);
        plot(data{j}.wav, P);
        v = str2double(data{j}.params.MeasuredVoltageCh2);
        i = str2double(data{j}.params.CurrentCh2)/4;
        leg_entries = [leg_entries, [num2str(v*i*1e3,'%.2f '), ' mW']];
        hold on; grid on;
    end
end
%title('Optimized TE1-TE0m Splitter - TE1 Output')
legend(leg_entries)
xlim([1520, 1580])
ylim([-25, 0])
%title(tcl,'Mode Modulator using Adjoint Optimized Y-Splitters. 900 um Heaters.')
format_plot(gca,'Wavelength (nm)','Insertion Loss (dB)', 5,'1c_double',9)
