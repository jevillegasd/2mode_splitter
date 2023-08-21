%% Optimized TE0 to TE1 Coupler

% Description: Adiabatic coupler used as a mode modulator. Tested for
% volatges between -2.0 amnd 0 volts. USes a 900 um heater.
die = "jvillegas";
circuits = ["TE1_topo_DEV03"];
outputs_ref = ["Output_1_test_TE"]; % Output + circuit
outputs = ["Output_1"];
colors = ['r','b'];
gauss_size = 100/10; %in 10s of pm
plot_step = 10;
heat_length = 100e-6*num_heaters;
i_mult = 1/2*1/2; % 2 circuits and 2 lines of heaters in parallel per circuit. All identical.

figure(1)
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
        v = str2double(data{j}.params.MeasuredVoltageCh1);
        ic = str2double(data{j}.params.CurrentCh1)*i_mult;
        leg_entries = [leg_entries, [num2str(round(v*ic/heat_length,2)), ' W/m']];
        hold on; grid on;
    end
end
title('Optimized TE1-TE0m Splitter - TE0 Output')
legend(leg_entries)
xlim([1520, 1580])

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
        v = str2double(data{j}.params.MeasuredVoltageCh1);
        ic = str2double(data{j}.params.CurrentCh1)*i_mult;
        leg_entries = [leg_entries, [num2str(round(v*ic/heat_length,2)), ' W/m']];
        hold on; grid on;
    end
end
title('Optimized TE1-TE0m Splitter - TE1 Output')
legend(leg_entries)
xlim([1520, 1580])
ylim([-30, 0])
title(tcl,'Mode Modulator using Adjoint Optimized Y-Splitters. TE1 Input - 200 um Heaters.')
